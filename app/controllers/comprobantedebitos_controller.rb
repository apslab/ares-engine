class ComprobantedebitosController < AuthorizedController
  before_filter :find_cliente
  before_filter :find_comprobantedebito, :except => [:index, :new, :create]

  # GET /comprobantedebitos
  # GET /comprobantedebitos.xml  
  def index
    @search = @cliente.comprobantedebitos.search(params[:search])
    @comprobantedebitos = @search.page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comprobantedebitos }
      format.pdf do
         dump_tmp_filename = Rails.root.join('tmp',@comprobantedebitos.first.cache_key)
         Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
         save_list_pdf_to(dump_tmp_filename,@comprobantedebitos) 
         send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "comprobantedebitos.pdf")
         File.delete(dump_tmp_filename)           
      end      
    end
  end

  # GET /comprobantedebitos/1
  # GET /comprobantedebitos/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comprobantedebito }
      format.pdf do
       
        unless @comprobantedebito.isprinted?
           @entry = @comprobantedebito.to_entry
           unless @entry.save
             flash[:error] = @entry.errors.full_messages.join("\n")
             redirect_to [@comprobantedebito.cliente]
             return
           end
        end
        
        dump_tmp_filename = Rails.root.join('tmp',@comprobantedebito.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        if @comprobantedebito.cliente.company.comprobantedebito_method_print.blank?
          @comprobantedebito.save_pdf_to(dump_tmp_filename) 
        else
          if @comprobantedebito.respond_to?(@comprobantedebito.cliente.company.comprobantedebito_method_print)
            @comprobantedebito.send( @comprobantedebito.cliente.company.comprobantedebito_method_print , dump_tmp_filename )
          end  
        end
        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@cliente.razonsocial}-comprobantedebito-#{@comprobantedebito.numero}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /comprobantedebitos/new
  # GET /comprobantedebitos/new.xml
  def new
    @comprobantedebito = @cliente.comprobantedebitos.build
    @comprobantedebito.fecha = Date.today
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comprobantedebito }
    end
  end

  # GET /comprobantedebitos/1/edit
  def edit
  end

  # POST /comprobantedebitos
  # POST /comprobantedebitos.xml
  def create
    @comprobantedebito = @cliente.comprobantedebitos.build(params[:comprobantedebito])

    respond_to do |format|
      if @comprobantedebito.save
        format.html { redirect_to([@cliente, @comprobantedebito], :notice => t('flash.actions.create.notice', :resource_name => Comprobantedebito.model_name.human)) }
        format.xml  { render :xml => @comprobantedebito, :status => :created, :location => [@cliente, @comprobantedebito] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comprobantedebito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comprobantedebitos/1
  # PUT /comprobantedebitos/1.xml
  def update
    respond_to do |format|
      if @comprobantedebito.update_attributes(params[:comprobantedebito])
        format.html { redirect_to([@cliente, @comprobantedebito], :notice => t('flash.actions.update.notice', :resource_name => Comprobantedebito.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comprobantedebito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comprobantedebitos/1
  # DELETE /comprobantedebitos/1.xml
  def destroy
    @comprobantedebito.destroy

    respond_to do |format|
      format.html { redirect_to(cliente_comprobantedebitos_url(@cliente)) }
      format.xml  { head :ok }
    end
  end

  protected 

  def find_cliente
    @cliente = Cliente.find(params[:cliente_id])
  end

  def find_comprobantedebito
    @comprobantedebito = @cliente.comprobantedebitos.find(params[:id])
  end
end
