require "ecr"
require "ecr/macros"

module Prax
  class Views
    macro render(name)
      String.build do |__str__|
        embed_ecr "#{{{__DIR__}}}/templates/{{name.id}}.ecr", "__str__"
      end
    end

    def initialize
      if ROOT.starts_with?(ENV["HOME"])
        @root = "~" + ROOT[ENV["HOME"].length..-1]
      else
        @root = ROOT
      end
    end

    def layout(@title, &block)
      render :layout
    end

    def application_not_found(@name, @host)
      layout "Application not found" do
        render :application_not_found
      end
    end

    def welcome
      layout "Welcome" do
        render :welcome
      end
    end

    #class Layout
    #  def initialize(@view)
    #  end

    #  ecr_file "#{__DIR__}/templates/layout.ecr"
    #end

    #class ApplicationNotFoundView
    #  def initialize(@name, @host)
    #  end

    #  ecr_file "#{__DIR__}/templates/application_not_found.ecr"
    #end
  end
end
