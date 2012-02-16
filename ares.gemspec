# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ares"
  s.version = "0.4.32"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["AP System"]
  s.date = "2012-02-16"
  s.description = "Adminsitracion de Ventas"
  s.email = "info@ap-sys.com.ar"
  s.extra_rdoc_files = [
    "LICENSE.txt"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "Rakefile",
    "VERSION",
    "app/controllers/clientes_controller.rb",
    "app/controllers/comprobantecreditos_controller.rb",
    "app/controllers/comprobantedebitos_controller.rb",
    "app/controllers/condicionivas_controller.rb",
    "app/controllers/empresas_controller.rb",
    "app/controllers/facturanotacreditos_controller.rb",
    "app/controllers/facturarecibos_controller.rb",
    "app/controllers/facturas_controller.rb",
    "app/controllers/notacreditos_controller.rb",
    "app/controllers/pages_controller.rb",
    "app/controllers/recibos_controller.rb",
    "app/controllers/tasaivas_controller.rb",
    "app/helpers/clientes_helper.rb",
    "app/helpers/condicionivas_helper.rb",
    "app/helpers/empresas_helper.rb",
    "app/helpers/facturadetalles_helper.rb",
    "app/helpers/facturanotacreditos_helper.rb",
    "app/helpers/facturarecibos_helper.rb",
    "app/helpers/facturas_helper.rb",
    "app/helpers/notacreditos_helper.rb",
    "app/helpers/pages_helper.rb",
    "app/helpers/recibos_helper.rb",
    "app/helpers/tasaivas_helper.rb",
    "app/models/cliente.rb",
    "app/models/comprobante.rb",
    "app/models/comprobantecredito.rb",
    "app/models/comprobantedebito.rb",
    "app/models/condicioniva.rb",
    "app/models/detalle.rb",
    "app/models/factura.rb",
    "app/models/facturanotacredito.rb",
    "app/models/facturarecibo.rb",
    "app/models/notacredito.rb",
    "app/models/recibo.rb",
    "app/models/tasaiva.rb",
    "app/stylesheets/application.sass",
    "app/stylesheets/apslabs-ie.sass",
    "app/stylesheets/apslabs.sass",
    "app/stylesheets/jquery.tipsy.sass",
    "app/stylesheets/partials/_base.sass",
    "app/stylesheets/partials/_jquery-ui.sass",
    "app/stylesheets/partials/_mixins-ie.sass",
    "app/stylesheets/partials/_mixins.sass",
    "app/stylesheets/partials/_style-ie.sass",
    "app/stylesheets/partials/_style.sass",
    "app/stylesheets/partials/attrtastic/_attrtastic_changes.sass",
    "app/stylesheets/partials/formtastic/_formtastic.sass",
    "app/stylesheets/partials/formtastic/_formtastic_changes.sass",
    "app/stylesheets/uniform.aristo.sass",
    "app/views/clientes/_filtros.html.erb",
    "app/views/clientes/_form.html.erb",
    "app/views/clientes/_sidebar.html.erb",
    "app/views/clientes/cuentacorriente.html.erb",
    "app/views/clientes/cuentacorriente.pdf.erb",
    "app/views/clientes/edit.html.erb",
    "app/views/clientes/index.html.haml",
    "app/views/clientes/list_account.html.erb",
    "app/views/clientes/new.html.erb",
    "app/views/clientes/show.html.erb",
    "app/views/comprobantecreditos/_detalle_fields.html.erb",
    "app/views/comprobantecreditos/_filtros.html.erb",
    "app/views/comprobantecreditos/_form.html.erb",
    "app/views/comprobantecreditos/edit.html.erb",
    "app/views/comprobantecreditos/index.html.erb",
    "app/views/comprobantecreditos/new.html.erb",
    "app/views/comprobantecreditos/show.html.erb",
    "app/views/comprobantedebitos/_detalle_fields.html.erb",
    "app/views/comprobantedebitos/_filtros.html.erb",
    "app/views/comprobantedebitos/_form.html.erb",
    "app/views/comprobantedebitos/edit.html.erb",
    "app/views/comprobantedebitos/index.html.erb",
    "app/views/comprobantedebitos/new.html.erb",
    "app/views/comprobantedebitos/show.html.erb",
    "app/views/condicionivas/_form.html.erb",
    "app/views/condicionivas/edit.html.erb",
    "app/views/condicionivas/index.html.haml",
    "app/views/condicionivas/new.html.erb",
    "app/views/condicionivas/show.html.erb",
    "app/views/facturadetalles/edit.html.erb",
    "app/views/facturadetalles/new.html.erb",
    "app/views/facturanotacreditos/_form.html.erb",
    "app/views/facturanotacreditos/edit.html.erb",
    "app/views/facturanotacreditos/index.html.erb",
    "app/views/facturanotacreditos/new.html.erb",
    "app/views/facturanotacreditos/show.html.erb",
    "app/views/facturarecibos/_form.html.erb",
    "app/views/facturarecibos/edit.html.erb",
    "app/views/facturarecibos/index.html.erb",
    "app/views/facturarecibos/new.html.erb",
    "app/views/facturarecibos/show.html.erb",
    "app/views/facturas/_detalle_fields.html.erb",
    "app/views/facturas/_filtros.html.erb",
    "app/views/facturas/_form.html.erb",
    "app/views/facturas/edit.html.erb",
    "app/views/facturas/index.html.erb",
    "app/views/facturas/new.html.erb",
    "app/views/facturas/show.html.erb",
    "app/views/notacreditos/_detalle_fields.html.erb",
    "app/views/notacreditos/_filtros.html.erb",
    "app/views/notacreditos/_form.html.erb",
    "app/views/notacreditos/edit.html.erb",
    "app/views/notacreditos/index.html.erb",
    "app/views/notacreditos/new.html.erb",
    "app/views/notacreditos/show.html.erb",
    "app/views/pages/about.html.erb",
    "app/views/pages/config.html.erb",
    "app/views/pages/contact.html.erb",
    "app/views/pages/help.html.erb",
    "app/views/pages/home.html.erb",
    "app/views/recibos/_detalle_fields.html.erb",
    "app/views/recibos/_filtros.html.erb",
    "app/views/recibos/_form.html.erb",
    "app/views/recibos/edit.html.erb",
    "app/views/recibos/index.html.erb",
    "app/views/recibos/new.html.erb",
    "app/views/recibos/show.html.erb",
    "app/views/tasaivas/_form.html.erb",
    "app/views/tasaivas/edit.html.erb",
    "app/views/tasaivas/index.html.haml",
    "app/views/tasaivas/new.html.erb",
    "app/views/tasaivas/show.html.erb",
    "ares.gemspec",
    "config/routes.rb",
    "lib/ares.rb",
    "lib/ares/engine.rb",
    "spec/ares_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/lguardiola/ares"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Proyecto Facturacion"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

