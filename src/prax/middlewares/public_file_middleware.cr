require "../mime"

module Prax
  module Middlewares
    class PublicFileMiddleware < Base
      def call(handler)
        file_path = path(handler)

        unless handler.app.proxyable?
          if directory?(file_path)
            file_path = File.join(file_path, "index.html")
          end
        end

        if file?(file_path)
          Prax.logger.debug { "serving '#{file_path}'" }
          stat = File::Stat.new(file_path)
          type = MIME_TYPES.fetch(File.extname(file_path).downcase, DEFAULT_MIME_TYPE)

          headers = [] of String
          headers << "Content-Type: #{type}"
          headers << "Content-Length: #{stat.size}"

          handler.reply(200, headers) do
            stream_file(handler.client, file_path)
          end
        elsif handler.app.proxyable?
          yield
        else
          Prax.logger.debug { "not found '#{file_path}'" }
          uri = URI.parse(handler.request.uri)
          handler.reply 404, handler.views.not_found(uri.path, handler.request.host)
        end
      end

      def path(handler)
        public_path = handler.app.path.public_path
        uri = URI.parse(handler.request.uri)
        File.join(public_path, uri.path.to_s)
      end

      def file?(file_path)
        File.exists?(file_path) && File.file?(file_path)
      end

      def directory?(file_path)
        File.exists?(file_path) && File.directory?(file_path)
      end

      def stream_file(client, file_path)
        buffer = Slice(UInt8).new(2048)

        File.open(file_path, "rb") do |file|
          while (read_bytes = file.read(buffer)) > 0
            client.write(buffer[0, read_bytes])
          end
        end
      end
    end
  end
end
