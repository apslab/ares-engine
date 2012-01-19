class FacturarecibosController < AuthorizedController
  # GET /facturarecibos
  # GET /facturarecibos.xml
  before_filter :find_cliente
  before_filter :find_facturarecibo, :except => [:index, :new, :create]

  def index
    @facturarecibos = Facturarecibo.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @facturarecibos }
    end
  end

  # GET /facturarecibos/1
  # GET /facturarecibos/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @facturarecibo }
    end
  end

  # GET /facturarecibos/new
  # GET /facturarecibos/new.xml
  def new
    @facturarecibo = Facturarecibo.new
    @facturarecibo.fecha = Date.today
    @cliente = Cliente.find(params[:cliente_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @facturarecibo }
    end
  end

  # GET /facturarecibos/1/edit
  def edit
  end

  # POST /facturarecibos
  # POST /facturarecibos.xml
  def create
    @factura = @cliente.facturas.find(@facturarecibo.factura_id)
    @facturarecibo = @factura.facturarecibos.build(params[:facturarecibo])
    
    respond_to do |format|
      if @facturarecibo.save
        format.html { redirect_to([@cliente, @facturarecibo], :notice => t('flash.actions.create.notice', :resource_name => Facturarecibo.model_name.human)) }
        format.xml  { render :xml => @facturarecibo, :status => :created, :location => [@cliente,@facturarecibo] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @facturarecibo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /facturarecibos/1
  # PUT /facturarecibos/1.xml
  def update
    respond_to do |format|
      if @facturarecibo.update_attributes(params[:facturarecibo])
        format.html { redirect_to([@cliente,@facturarecibo], :notice => t('flash.actions.update.notice', :resource_name => Facturarecibo.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @facturarecibo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /facturarecibos/1
  # DELETE /facturarecibos/1.xml
  def destroy
    @facturarecibo = Facturarecibo.find(params[:id])
    @facturarecibo.destroy

    respond_to do |format|
      format.html { redirect_to(cliente_factura(@cliente,@facturarecibo.factura)) }
      format.xml  { head :ok }
    end
  end

  protected 

  def find_cliente
    @cliente = Cliente.find(params[:cliente_id])
  end

  def find_facturarecibo
    @facturarecibo = Facturarecibo.find(params[:id])
  end
end
