class CondicionivasController < AuthorizedController
  # GET /condicionivas
  # GET /condicionivas.xml
  before_filter :filter_condicioniva, :only => [:show,:edit,:update,:destroy]
  
  def index
    #@condicionivas = Condicioniva.all

    @search = Condicioniva.by_company(current_company).search(params[:search])
    @condicionivas = @search.order("detalle").page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @condicionivas }
      format.pdf do
         dump_tmp_filename = Rails.root.join('tmp',@condicionivas.first.cache_key)
         Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
         save_list_pdf_to(dump_tmp_filename,@condicionivas) 
         send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "condicionivas.pdf")
         File.delete(dump_tmp_filename)           
      end      
    end
  end

  # GET /condicionivas/1
  # GET /condicionivas/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @condicioniva }
      format.pdf do
        dump_tmp_filename = Rails.root.join('tmp',@condicioniva.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        save_pdf_to(dump_tmp_filename,@condicioniva)
        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@condicioniva.detalle}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /condicionivas/new
  # GET /condicionivas/new.xml
  def new
    @condicioniva = Condicioniva.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @condicioniva }
    end
  end

  # GET /condicionivas/1/edit
  def edit
  end

  # POST /condicionivas
  # POST /condicionivas.xml
  def create
    @condicioniva = Condicioniva.new(params[:condicioniva].update(:empresa_id => current_company.id))

    respond_to do |format|
      if @condicioniva.save
        format.html { redirect_to(@condicioniva, :notice => 'Condicioniva was successfully created.') }
        format.xml  { render :xml => @condicioniva, :status => :created, :location => @condicioniva }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @condicioniva.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /condicionivas/1
  # PUT /condicionivas/1.xml
  def update
    respond_to do |format|
      if @condicioniva.update_attributes(params[:condicioniva])
        format.html { redirect_to(@condicioniva, :notice => 'Condicioniva was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @condicioniva.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /condicionivas/1
  # DELETE /condicionivas/1.xml
  def destroy
    @condicioniva.destroy

    respond_to do |format|
      format.html { redirect_to(condicionivas_url) }
      format.xml  { head :ok }
    end
  end
  
protected 
  # filtro general protejido
  def filter_condicioniva
      @condicioniva = Condicioniva.by_company(current_company).find( params[:id] )
  end
end
