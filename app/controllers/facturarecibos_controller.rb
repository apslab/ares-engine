class FacturarecibosController < AuthorizedController
  # GET /facturarecibos
  # GET /facturarecibos.xml
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
    @facturarecibo = Facturarecibo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @facturarecibo }
    end
  end

  # GET /facturarecibos/new
  # GET /facturarecibos/new.xml
  def new
    @facturarecibo = Facturarecibo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @facturarecibo }
    end
  end

  # GET /facturarecibos/1/edit
  def edit
    @facturarecibo = Facturarecibo.find(params[:id])
  end

  # POST /facturarecibos
  # POST /facturarecibos.xml
  def create
    @facturarecibo = Facturarecibo.new(params[:facturarecibo])

    respond_to do |format|
      if @facturarecibo.save
        format.html { redirect_to(@facturarecibo, :notice => t('flash.actions.create.notice', :resource_name => Facturarecibo.model_name.human)) }
        format.xml  { render :xml => @facturarecibo, :status => :created, :location => @facturarecibo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @facturarecibo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /facturarecibos/1
  # PUT /facturarecibos/1.xml
  def update
    @facturarecibo = Facturarecibo.find(params[:id])

    respond_to do |format|
      if @facturarecibo.update_attributes(params[:facturarecibo])
        format.html { redirect_to(@facturarecibo, :notice => t('flash.actions.update.notice', :resource_name => Facturarecibo.model_name.human)) }
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
      format.html { redirect_to(facturarecibos_url) }
      format.xml  { head :ok }
    end
  end
end
