require 'tempfile'

class Textfile < Pathname
  # OS X comm can't handle lines > 2K bytes.
  # See http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
  COMM_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gcomm' : 'comm')
  SORT_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gsort' : 'sort')
  UNIQ_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'guniq' : 'uniq')

  def initialize(p1, options = {})
    @debug = options[:debug]
    @lang = options[:lang]
    super(p1)
  end

  # Sorts file and removes any duplicate records.
  def sort(options='')
    options.concat(" --buffer-size=#{@bufsiz}") if @bufsiz
    with_tempcopy do |tempcopy|
      sh "#{SORT_CMD} #{options} #{tempcopy} | #{UNIQ_CMD} > #{self}"
    end
  end

  protected
  def sh(cmd)
    cmd = "export LC_COLLATE=#{@lang}; #{cmd}" if @lang
    puts cmd if @debug
    %x[ #{cmd} ]
    self
  end

  def with_tempcopy
    tempcopy = Tempfile.new(self.class.name)
    tempcopy.write(self.read)
    tempcopy.close
    yield tempcopy.path
    tempcopy.unlink unless @debug
    self
  end
end