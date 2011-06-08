class ClientesController < AuthorizedController
  # GET /clientes
  # GET /clientes.xml
  before_filter :filter_customer, :only => [:show,:edit,:update,:destroy,:cuentacorriente]
  
  def index
#    @search = current_company.clientes.search(params[:search])

    @search = Cliente.by_company(current_company).search(params[:search])
    @clientes = @search.order("razonsocial").page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clientes }
    end
  end

  # GET /clientes/1
  # GET /clientes/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cliente }
      format.pdf { render :pdf => "cta"+@cliente.razonsocial,
                       :template => 'clientes/show.html.erb',
                       :show_as_html => params[:debug].present?,      # allow debuging based on url param
                       :layout => 'pdf.html.erb',
                       :footer => {
                          :right => "Reporte generado el #{l DateTime.current}"
                       }
                 }
    end
  end

  # GET /clientes/new
  # GET /clientes/new.xml
  def new
#    @cliente = Cliente.new
#    @cliente.empresa_id = current_company.id
# esto reemplaza las dos lineas anteriores

    @cliente = current_company.clientes.build
    
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
    @cliente = Cliente.new(params[:cliente].update(:empresa_id => current_company.id))

    respond_to do |format|
      if @cliente.save
        format.html { redirect_to(@cliente, :notice => 'Cliente was successfully created.') }
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
        format.html { redirect_to(@cliente, :notice => 'Cliente was successfully updated.') }
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
    format.pdf { render :pdf => "cc_#{@cliente.id}",
                     :template => 'clientes/cuentacorriente.html.erb',
                     :show_as_html => params[:debug].present?,      # allow debuging based on url param
                     :layout => 'pdf.html.erb',
                     :footer => { :right => "Reporte generado el #{l DateTime.current}" }
               }
  end
end

def list_accounts
  #begin
    @accounts = Account.all()

    respond_to do |format|
      format.html { redirect_to( clientes_url ) }
      format.xml  { head :ok }
    end
  #rescue ActiveResource::ResourceNotFound, ActiveResource::Redirection, ActiveResource::ResourceInvalid
  #  redirect_to("404.html")
  #ensure
    # redirect_to("404.html")
    # paso siempre por aca
  #end
end

protected 
# filtro general protejido
  def filter_customer
    @cliente = Cliente.by_company(current_company).find( params[:id] )
  end
end