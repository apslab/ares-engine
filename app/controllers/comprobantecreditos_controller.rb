class ComprobantecreditosController < AuthorizedController
  before_filter :find_cliente
  before_filter :find_comprobantecredito, :except => [:index, :new, :create]

  # GET /comprobantecreditos
  # GET /comprobantecreditos.xml  
  def index
    @search = @cliente.comprobantecreditos.search(params[:search])
    @comprobantecreditos = @search.page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comprobantecreditos }
      format.pdf do
         dump_tmp_filename = Rails.root.join('tmp',@comprobantecreditos.first.cache_key)
         Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
         save_list_pdf_to(dump_tmp_filename,@comprobantecreditos) 
         send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "comprobantecreditos.pdf")
         File.delete(dump_tmp_filename)           
      end      
    end
  end

  # GET /comprobantecreditos/1
  # GET /comprobantecreditos/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comprobantecredito }
      format.pdf do
       
        unless @comprobantecredito.isprinted?
           @entry = @comprobantecredito.to_entry
           unless @entry.save
             flash[:error] = @entry.errors.full_messages.join("\n")
             redirect_to [@comprobantecredito.cliente]
             return
           end
        end
        
        dump_tmp_filename = Rails.root.join('tmp',@comprobantecredito.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        if @comprobantecredito.cliente.company.comprobantecredito_method_print.blank?
          @comprobantecredito.save_pdf_to(dump_tmp_filename) 
        else
          if @comprobantecredito.respond_to?(@comprobantecredito.cliente.company.comprobantecredito_method_print)
            @comprobantecredito.send( @comprobantecredito.cliente.company.comprobantecredito_method_print , dump_tmp_filename )
          end  
        end
        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@cliente.razonsocial}-comprobantecredito-#{@comprobantecredito.numero}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /comprobantecreditos/new
  # GET /comprobantecreditos/new.xml
  def new
    @comprobantecredito = @cliente.comprobantecreditos.build
    @comprobantecredito.fecha = Date.today
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comprobantecredito }
    end
  end

  # GET /comprobantecreditos/1/edit
  def edit
  end

  # POST /comprobantecreditos
  # POST /comprobantecreditos.xml
  def create
    @comprobantecredito = @cliente.comprobantecreditos.build(params[:comprobantecredito])

    respond_to do |format|
      if @comprobantecredito.save
        format.html { redirect_to([@cliente, @comprobantecredito], :notice => t('flash.actions.create.notice', :resource_name => comprobantecredito.model_name.human)) }
        format.xml  { render :xml => @comprobantecredito, :status => :created, :location => [@cliente, @comprobantecredito] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comprobantecredito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comprobantecreditos/1
  # PUT /comprobantecreditos/1.xml
  def update
    respond_to do |format|
      if @comprobantecredito.update_attributes(params[:comprobantecredito])
        format.html { redirect_to([@cliente, @comprobantecredito], :notice => t('flash.actions.update.notice', :resource_name => comprobantecredito.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comprobantecredito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comprobantecreditos/1
  # DELETE /comprobantecreditos/1.xml
  def destroy
    @comprobantecredito.destroy

    respond_to do |format|
      format.html { redirect_to(cliente_comprobantecreditos_url(@cliente)) }
      format.xml  { head :ok }
    end
  end

  protected 

  def find_cliente
    @cliente = Cliente.find(params[:cliente_id])
  end

  def find_comprobantecredito
    @comprobantecredito = @cliente.comprobantecreditos.find(params[:id])
  end
end
