class TasaivasController < AuthorizedController
  # GET /tasaivas
  # GET /tasaivas.xml
  before_filter :filter_tasaiva, :only => [:show,:edit,:update,:destroy]
  
  def index
    @tasaivas = Tasaiva.by_company(current_company).all()
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasaivas }
    end
  end

  # GET /tasaivas/1
  # GET /tasaivas/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tasaiva }
    end
  end

  # GET /tasaivas/new
  # GET /tasaivas/new.xml
  def new
    @tasaiva = current_company.tasaivas.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tasaiva }
    end
  end

  # GET /tasaivas/1/edit
  def edit
  end

  # POST /tasaivas
  # POST /tasaivas.xml
  def create
    @tasaiva = Tasaiva.new(params[:tasaiva].update(:company_id => current_company.id))

    respond_to do |format|
      if @tasaiva.save
        format.html { redirect_to(@tasaiva, :notice => 'Tasaiva was successfully created.') }
        format.xml  { render :xml => @tasaiva, :status => :created, :location => @tasaiva }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tasaiva.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasaivas/1
  # PUT /tasaivas/1.xml
  def update

    respond_to do |format|
      if @tasaiva.update_attributes(params[:tasaiva])
        format.html { redirect_to(@tasaiva, :notice => 'Tasaiva was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tasaiva.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasaivas/1
  # DELETE /tasaivas/1.xml
  def destroy
    @tasaiva.destroy

    respond_to do |format|
      format.html { redirect_to(tasaivas_url) }
      format.xml  { head :ok }
    end
  end
  
  protected 
  # filtro general protejido
  def filter_tasaiva
    @tasaiva = Tasaiva.by_company(current_company).find( params[:id] )
  end
end
