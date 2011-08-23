class FacturanotacreditosController < AuthorizedController
  # GET /facturanotacreditos
  # GET /facturanotacreditos.xml
  def index
    @facturanotacreditos = Facturanotacredito.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @facturanotacreditos }
    end
  end

  # GET /facturanotacreditos/1
  # GET /facturanotacreditos/1.xml
  def show
    @facturanotacredito = Facturanotacredito.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @facturanotacredito }
    end
  end

  # GET /facturanotacreditos/new
  # GET /facturanotacreditos/new.xml
  def new
    @facturanotacredito = Facturanotacredito.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @facturanotacredito }
    end
  end

  # GET /facturanotacreditos/1/edit
  def edit
    @facturanotacredito = Facturanotacredito.find(params[:id])
  end

  # POST /facturanotacreditos
  # POST /facturanotacreditos.xml
  def create
    @facturanotacredito = Facturanotacredito.new(params[:facturanotacredito])

    respond_to do |format|
      if @facturanotacredito.save
        format.html { redirect_to(@facturanotacredito, :notice => t('flash.actions.create.notice', :resource_name => Facturanotacredito.model_name.human)) }
        format.xml  { render :xml => @facturanotacredito, :status => :created, :location => @facturanotacredito }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @facturanotacredito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /facturanotacreditos/1
  # PUT /facturanotacreditos/1.xml
  def update
    @facturanotacredito = Facturanotacredito.find(params[:id])

    respond_to do |format|
      if @facturanotacredito.update_attributes(params[:facturanotacredito])
        format.html { redirect_to(@facturanotacredito, :notice => t('flash.actions.update.notice', :resource_name => Facturanotacredito.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @facturanotacredito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /facturanotacreditos/1
  # DELETE /facturanotacreditos/1.xml
  def destroy
    @facturanotacredito = Facturanotacredito.find(params[:id])
    @facturanotacredito.destroy

    respond_to do |format|
      format.html { redirect_to(facturanotacreditos_url) }
      format.xml  { head :ok }
    end
  end
end
