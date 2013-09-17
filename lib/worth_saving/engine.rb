module WorthSaving
  class Engine < ::Rails::Engine
    isolate_namespace WorthSaving
    config.default_save_interval = 60
    config.default_recovery_message = <<EOS
It appears you were working on a draft that didn't get saved.
It is recommended that you choose one now, as no more draft copies will be saved until you do.
EOS
  end

  def self.configure(&block)
    yield Engine.config if block
    Engine.config
  end
end
