class RecibosController < AuthorizedController
  before_filter :find_cliente
  before_filter :find_recibo, :except => [:index, :new, :create]

  # GET /recibos
  # GET /recibos.xml
  
  def index
    @search = @cliente.recibos.search(params[:search])
    @recibos = @search.page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recibos }
      format.pdf do
         dump_tmp_filename = Rails.root.join('tmp',@recibos.first.cache_key)
         Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
         save_list_pdf_to(dump_tmp_filename,@recibos) 
         send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "recibos.pdf")
         File.delete(dump_tmp_filename)           
      end      
    end
  end

  # GET /recibos/1
  # GET /recibos/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @recibo }
      format.pdf do
       
        unless @recibo.isprinted?
           @entry = @recibo.to_entry
           unless @entry.save
             flash[:error] = @entry.errors.full_messages.join("\n")
             redirect_to [@recibo.cliente]
             return
           end
        end
        
        dump_tmp_filename = Rails.root.join('tmp',@recibo.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        if @recibo.cliente.company.recibo_method_print.blank?
          @recibo.save_pdf_to(dump_tmp_filename) 
        else
          if @recibo.respond_to?(@recibo.cliente.company.recibo_method_print)
            @recibo.send( @recibo.cliente.company.recibo_method_print , dump_tmp_filename )
          end  
        end
        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@cliente.razonsocial}-recibo-#{@recibo.numero}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /recibos/new
  # GET /recibos/new.xml
  def new
    @recibo = @cliente.recibos.build
    @recibo.fecha = Date.today
    @recibo.detalles.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recibo }
    end
  end

  # GET /recibos/1/edit
  def edit
  end

  # POST /recibos
  # POST /recibos.xml
  def create
    @recibo = @cliente.recibos.build(params[:recibo])
    @recibo.detalles.each do |detalle|
      detalle.cantidad = 1
    end

    respond_to do |format|
      if @recibo.save
        format.html { redirect_to([@cliente, @recibo], :notice => t('flash.actions.create.notice', :resource_name => Recibo.model_name.human)) }
        format.xml  { render :xml => @recibo, :status => :created, :location => [@cliente, @recibo] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recibo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recibos/1
  # PUT /recibos/1.xml
  def update
    respond_to do |format|
      if @recibo.update_attributes(params[:recibo])
        @recibo.detalles.each do |detalle|
          detalle.cantidad = 1
        end
        format.html { redirect_to([@cliente, @recibo], :notice => t('flash.actions.update.notice', :resource_name => Recibo.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recibo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recibos/1
  # DELETE /recibos/1.xml
  def destroy
    @recibo.destroy

    respond_to do |format|
      format.html { redirect_to(cliente_recibos_url(@cliente)) }
      format.xml  { head :ok }
    end
  end

  protected 

  def find_cliente
    @cliente = Cliente.find(params[:cliente_id])
  end

  def find_recibo
    @recibo = @cliente.recibos.find(params[:id])
  end
end
