module WorthSaving
  class Engine < ::Rails::Engine
    isolate_namespace WorthSaving
    config.default_save_interval = 60
    config.default_recovery_message = <<EOS
It appears you were working on a draft that didn't get saved.
It is recommended that you choose one now, as no more draft copies will be saved until you do.
EOS
    config.additional_namespaces = []
    config.after_initialize do
      config.additional_namespaces.each do |space|
        space = space.to_s.camelize
        WorthSaving.module_eval <<EOS
          module #{space}
            class DraftsController < Rails::Application::#{space}Controller
              include WorthSaving::DraftsControllerMethods
            end
          end
EOS
      end
    end
  end

  def self.configure(&block)
    yield Engine.config if block
    Engine.config
  end
end
