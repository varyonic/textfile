require 'tempfile'

class Textfile
  # OS X comm can't handle lines > 2K bytes.
  # See http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
  COMM_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gcomm' : 'comm')
  SORT_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gsort' : 'sort')
  UNIQ_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'guniq' : 'uniq')

  attr_accessor :path

  def initialize(p1, options = {})
    @debug = options[:debug]
    @lang = options[:lang]
    @path = p1
  end

  # Removes all elements and returns self.
  def clear
    sh "cat /dev/null > #{@path}"
  end

  def comm(textfile, options)
    with_tempcopy do |tempcopy|
      sh "#{COMM_CMD} #{options} #{tempcopy} #{textfile.path} > #{@path}"
    end
  end

  # Returns a new textfile containing rows common to the current textfile and another.
  # Both self and textfile must be sorted.
  def &(textfile)
    comm(textfile, '-12')
  end
  alias_method :intersection, :&

  # Merges the contents of other textfiles and returns self.
  def merge(*textfiles)
    sh "cat #{textfiles.map(&:path).join(' ')}|tr '\\r' '\\n'>> #{@path}"
  end

  # Sorts file and removes any duplicate records.
  def sort(options='')
    options.concat(" --buffer-size=#{@bufsiz}") if @bufsiz
    with_tempcopy do |tempcopy|
      sh "#{SORT_CMD} #{options} #{tempcopy} | #{UNIQ_CMD} > #{@path}"
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
    tempcopy = Tempfile.new(['temp-','.txt'])
    tempcopy.write(File.read(@path))
    tempcopy.close
    yield tempcopy.path
    tempcopy.unlink unless @debug
    self
  end
end