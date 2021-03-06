require 'logger'
require 'tempfile'

class Textfile

  attr_accessor :path, :tmpdir, :logger, :debug

  # options
  # * +:bufsiz+ - Passed to GNU sort to optimize performance.
  # * +:debug+ - Suppress deletion of temp files.
  # * +:lang+ - Collation sequence.
  # * +:logger+ - Logs shell commands and resulting ouput (default: STDOUT).
  def initialize(path, options = {})
    @bufize = options[:bufsiz]
    @debug = options[:debug]
    @lang = options[:lang] || 'en_US.UTF-8'
    @logger = options[:logger] || Logger.new(STDOUT)
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
    sh "cat #{textfiles.map(&:path).join(' ')} >> #{@path}"
    self.sort
  end

  # Remove records present in other textfile.
  def subtract(textfile)
    # --nocheck-order, see https://bugzilla.redhat.com/show_bug.cgi?id=1001775
    comm(textfile, '--nocheck-order -23')
  end

  protected
  # OS X comm can't handle lines > 2K bytes.
  # See http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
  def comm_cmd() (RUBY_PLATFORM =~ /darwin/ ? 'gcomm' : 'comm') end
  def sort_cmd() (RUBY_PLATFORM =~ /darwin/ ? 'gsort' : 'sort') end
  def uniq_cmd() (RUBY_PLATFORM =~ /darwin/ ? 'guniq' : 'uniq') end

  def comm(textfile, options)
    self.sort
    textfile.sort
    with_tempcopy do |tempcopy|
      sh "#{comm_cmd} #{options} #{tempcopy} #{textfile.path} > #{@path}"
    end
  end

  def sh(cmd)
    cmd = "export LC_COLLATE=#{@lang}; #{cmd}" if @lang
    logger.info cmd;
    logger.info %x[ #{cmd} ] # TODO: capture $?
    self
  end

  # Sorts file and removes any duplicate records.
  def sort
    return self if sorted
    options = "--buffer-size=#{@bufsiz}" if @bufsiz
    with_tempcopy do |tempcopy|
      sh "#{sort_cmd} #{options} #{tempcopy} | #{uniq_cmd} > #{@path}"
    end
    @sorted = true
    self
  end
  attr_accessor :sorted

  def with_tempcopy
    tempcopy = Tempfile.new(['temp-','.txt'], tmpdir)
    tempcopy.write(File.read(@path))
    tempcopy.close
    yield tempcopy.path
    tempcopy.unlink unless @debug
    self
  end
end