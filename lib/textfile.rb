require 'tempfile'

class Textfile
  # OS X comm can't handle lines > 2K bytes.
  # See http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
  COMM_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gcomm' : 'comm')
  SORT_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gsort' : 'sort')
  UNIQ_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'guniq' : 'uniq')

  attr_accessor :path

  def initialize(path, options = {})
    @debug = options[:debug]
    @lang = options[:lang]
    @path = path
  end

  # Removes all records.
  def clear
    sh "cat /dev/null > #{@path}"
  end

  # Removes records not present in other textfile.
  def intersection(textfile)
    comm(textfile, '-12')
  end

  # Merges the contents of other textfiles and returns self.
  def merge(*textfiles)
    sh "cat #{textfiles.map(&:path).join(' ')}|tr '\\r' '\\n'>> #{@path}"
    self.sort
  end

  # Remove records present in other textfile.
  def subtract(textfile)
    comm(textfile, '-23')
  end

  protected
  def comm(textfile, options)
    self.sort
    textfile.sort
    with_tempcopy do |tempcopy|
      sh "#{COMM_CMD} #{options} #{tempcopy} #{textfile.path} > #{@path}"
    end
  end

  def sh(cmd)
    cmd = "export LC_COLLATE=#{@lang}; #{cmd}" if @lang
    puts cmd if @debug
    %x[ #{cmd} ]
    self
  end

  # Sorts file and removes any duplicate records.
  def sort
    return self if sorted
    options = "--buffer-size=#{@bufsiz}" if @bufsiz
    with_tempcopy do |tempcopy|
      sh "#{SORT_CMD} #{options} #{tempcopy} | #{UNIQ_CMD} > #{@path}"
    end
    @sorted = true
    self
  end
  attr_accessor :sorted

  def with_tempcopy
    tempcopy = Tempfile.new(['temp-','.txt'])
    tempcopy.write(File.read(@path))
    tempcopy.close
    yield tempcopy.path
    tempcopy.unlink unless @debug
    self
  end
end