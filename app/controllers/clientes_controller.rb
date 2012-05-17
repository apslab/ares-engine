class ClientesController < AuthorizedController
  # GET /clientes
  # GET /clientes.xml
  before_filter :filter_customer, :only => [:show,:edit,:update,:destroy,:cuentacorriente]
  
  def index
    @search = Cliente.by_company(current_company).search(params[:search])
    @clientes = @search.order("razonsocial").page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clientes }
      format.pdf do
         dump_tmp_filename = Rails.root.join('tmp',@clientes.first.cache_key)
         Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
         save_list_pdf_to(dump_tmp_filename,@clientes) 
         send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "clientes.pdf")
         File.delete(dump_tmp_filename)           
      end
    end
  end

  # GET /clientes/1
  # GET /clientes/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cliente }
      format.pdf do
        dump_tmp_filename = Rails.root.join('tmp',@cliente.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        save_pdf_to(dump_tmp_filename,@cliente)
        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@cliente.razonsocial}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /clientes/new
  # GET /clientes/new.xml
  def new
    @cliente = current_company.clientes.build
    #@cliente.addresses.build
    #@cliente.phones.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cliente }
    end
  end

  # GET /clientes/1/edit
  def edit
  end

  # POST /clientes
  # POST /clientes.xml
  def create
    @cliente = Cliente.new(params[:cliente].update(:company_id => current_company.id))

    respond_to do |format|
      if @cliente.save
        format.html { redirect_to(@cliente, :notice => t('flash.actions.create.notice', :resource_name => Cliente.model_name.human)) }
        format.xml  { render :xml => @cliente, :status => :created, :location => @cliente }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cliente.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clientes/1
  # PUT /clientes/1.xml
  def update
    respond_to do |format|
      if @cliente.update_attributes(params[:cliente])
        format.html { redirect_to(@cliente, :notice => t('flash.actions.update.notice', :resource_name => Cliente.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cliente.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clientes/1
  # DELETE /clientes/1.xml
  def destroy
    @cliente.destroy
    flash[:error] = @cliente.errors.full_messages.join('<br />') unless @cliente.errors.empty?
    
    respond_to do |format|
      format.html { redirect_to(clientes_url) }
      format.xml  { head :ok }
    end
  end


def cuentacorriente
  @cuentacorriente = @cliente.comprobantes.order("fecha")
  respond_to do |format|
    format.html # .html.erb
    format.xml  { render :xml => @cliente }
    format.pdf do      
      dump_tmp_filename = Rails.root.join('tmp',@cliente.cache_key)
      Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
      @cliente.save_ctacte_pdf_to(dump_tmp_filename,@cuentacorriente)
      send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@cliente.razonsocial}-ctacte.pdf")
      File.delete(dump_tmp_filename)
    end
  end
end

def list_accounts
  @accounts = Account.all()

  respond_to do |format|
    format.html { redirect_to( clientes_url ) }
    format.xml  { head :ok }
  end
end

protected 
# filtro general protejido
  def filter_customer
    @cliente = Cliente.by_company(current_company).find( params[:id] )
  end
end