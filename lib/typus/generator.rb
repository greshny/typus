module Typus

  def self.generator

    logger = Logger.new("#{Rails.root}/log/#{Rails.env}.log")

    # Create app/controllers/admin if doesn't exist.
    admin_controllers_folder = "#{Rails.root}/app/controllers/admin"
    Dir.mkdir(admin_controllers_folder) unless File.directory?(admin_controllers_folder)

    # Get a list of all available app/controllers/admin
    admin_controllers = Dir["#{Rails.root}/vendor/plugins/*/app/controllers/admin/*.rb", "#{admin_controllers_folder}/*.rb"]
    admin_controllers = admin_controllers.map { |i| File.basename(i) }

    # Create app/views/admin if doesn't exist.
    admin_views_folder = "#{Rails.root}/app/views/admin"
    Dir.mkdir(admin_views_folder) unless File.directory?(admin_views_folder)

    # Create test/functional/admin if doesn't exist.
    admin_controller_tests_folder = "#{Rails.root}/test/functional/admin"
    if File.directory?("#{Rails.root}/test")
      Dir.mkdir(admin_controller_tests_folder) unless File.directory?(admin_controller_tests_folder)
    end

    # Get a list of all available functional test for admin.
    admin_controller_tests = Dir["#{Rails.root}/vendor/plugins/*/test/functional/admin/*.rb", "#{admin_controller_tests_folder}/*.rb"]
    admin_controller_tests = admin_controller_tests.map { |i| File.basename(i) }

    # Generate unexisting controllers for resources which are not tied to
    # a model.
    resources.each do |resource|

      controller_filename = "#{resource.underscore}_controller.rb"
      controller_location = "#{admin_controllers_folder}/#{controller_filename}"

      if !admin_controllers.include?(controller_filename)
        controller = File.open(controller_location, "w+")
        content = <<-RAW
# Controller generated by Typus, use it to extend admin functionality.
class Admin::#{resource}Controller < TypusController

  ##
  # This controller was generated because you have defined a resource 
  # which is not tied to a model on your <tt>config/typus/XXXXXX_roles.yml</tt> 
  # configuration file.
  #
  #     admin:
  #       #{resource}: index
  #

  def index
  end

end
      RAW

        controller.puts(content)
        controller.close
        logger.info "=> [typus] Admin::#{resource}Controller successfully created."

      end

      # And now we create the view.
      view_folder = "#{admin_views_folder}/#{resource.underscore}"
      view_filename = "index.html.erb"

      if !File.exists?("#{view_folder}/#{view_filename}")
        Dir.mkdir(view_folder) unless File.directory?(view_folder)
        view = File.open("#{view_folder}/#{view_filename}", "w+")
        content = <<-RAW
<!-- Sidebar -->

<% content_for :sidebar do %>
<%= typus_block :location => 'dashboard', :partial => 'sidebar' %>
<% end %>

<!-- Content -->

<h2><%= link_to _('Dashboard'), admin_dashboard_path %> &rsaquo; #{resource.humanize}</h2>

<p>And here we do whatever we want to ...</p>

        RAW
        view.puts(content)
        view.close
        logger.info "=> [typus] app/views/admin/#{resource.underscore}/index.html.erb successfully created."
      end

    end

    # Generate unexisting controllers for resources which are tied to a 
    # model.
    models.each do |model|

      # Controller app/controllers/admin/*
      controller_filename = "#{model.tableize}_controller.rb"
      controller_location = "#{admin_controllers_folder}/#{controller_filename}"

      if !admin_controllers.include?(controller_filename)
        controller = File.open(controller_location, "w+")

        content = <<-RAW
# Controller generated by Typus, use it to extend admin functionality.
class Admin::#{model.pluralize}Controller < Admin::MasterController

=begin

  ##
  # You can overwrite any Admin::MasterController methods.
  #
  def index
  end

=end

=begin

  ##
  # You can extend Admin::MasterController with your methods.
  #
  # This actions have to be defined in <tt>config/typus/application.yml</tt>.
  #
  #   #{model}:
  #     actions:
  #       index: custom_action
  #       edit: custom_action_for_an_item
  #
  def custom_action
  end

  def custom_action_for_an_item
  end

=end

end
        RAW

        controller.puts(content)
        controller.close
        logger.info "=> [typus] Admin::#{model.pluralize}Controller successfully created."
      end

      # Test test/functional/admin/*_test.rb
      test_filename = "#{model.tableize}_controller_test.rb"
      test_location = "#{admin_controller_tests_folder}/#{test_filename}"

      if !admin_controller_tests.include?(test_filename) && File.directory?("#{Rails.root}/test")
        test = File.open(test_location, "w+")

        content = <<-RAW
require 'test_helper'

class Admin::#{model.pluralize}ControllerTest < ActionController::TestCase

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

end
        RAW

        test.puts(content)
        test.close
        logger.info "=> [typus] Admin::#{model.pluralize}ControllerTest successfully created."
      end

    end

  end

end