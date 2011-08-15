class TasaivasController < AuthorizedController
  # GET /tasaivas
  # GET /tasaivas.xml
  before_filter :filter_tasaiva, :only => [:show,:edit,:update,:destroy]

  respond_to :html, :xml, :json
  
  def index
    @search = Tasaiva.by_company(current_company).search(params[:search])
    @tasaivas = @search.order("detalle").page(params[ :page ]).per(10)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasaivas }
      format.pdf do
         dump_tmp_filename = Rails.root.join('tmp',@tasaivas.first.cache_key)
         Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
         save_list_pdf_to(dump_tmp_filename,@tasaivas) 
         send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "tasaivas.pdf")
         File.delete(dump_tmp_filename)           
      end
    end
  end

  # GET /tasaivas/1
  # GET /tasaivas/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tasaiva }
      format.pdf do
        dump_tmp_filename = Rails.root.join('tmp',@tasaiva.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        save_pdf_to(dump_tmp_filename,@tasaiva)
        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@tasaiva.detalle}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /tasaivas/new
  # GET /tasaivas/new.xml
  def new
    @tasaiva = current_company.tasaivas.build
    respond_with(@tasaiva)
  
    #@tasaiva = current_company.tasaivas.build
    #respond_to do |format|
    #  format.html # new.html.erb
    #  format.xml  { render :xml => @tasaiva }
    #end
  end

  # GET /tasaivas/1/edit
  def edit
  end

  # POST /tasaivas
  # POST /tasaivas.xml
  def create
    @tasaiva = Tasaiva.new(params[:tasaiva].update(:company_id => current_company.id))
    flash[:notice] = t('scaffold.notice.created', :item => Tasaiva.model_name.human) if @tasaiva.save
    respond_with(@tasaiva, :location => tasaivas_path)
        
    #@tasaiva = Tasaiva.new(params[:tasaiva].update(:company_id => current_company.id))

    #respond_to do |format|
    #  if @tasaiva.save
    #    format.html { redirect_to(@tasaiva, :notice => 'Tasaiva was successfully created.') }
    #    format.xml  { render :xml => @tasaiva, :status => :created, :location => @tasaiva }
    #  else
    #    format.html { render :action => "new" }
    #    format.xml  { render :xml => @tasaiva.errors, :status => :unprocessable_entity }
    #  end
    #end
  end

  # PUT /tasaivas/1
  # PUT /tasaivas/1.xml
  def update
    flash[:notice] = t('scaffold.notice.updated', :item => Tasaiva.model_name.human) if @tasaiva.update_attributes(params[:tasaiva])
    respond_with(@tasaiva, :location => products_path)

    #respond_to do |format|
    #  if @tasaiva.update_attributes(params[:tasaiva])
    #    format.html { redirect_to(@tasaiva, :notice => 'Tasaiva was successfully updated.') }
    #    format.xml  { head :ok }
    #  else
    #    format.html { render :action => "edit" }
    #    format.xml  { render :xml => @tasaiva.errors, :status => :unprocessable_entity }
    #  end
    #end
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