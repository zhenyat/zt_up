module ZtUp
  class Railtie < Rails::Railtie
    # for example, if you want to extend ViewHelpers
    initializer 'zt_up.view_helpers' do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end