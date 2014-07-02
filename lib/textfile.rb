require 'tempfile'

class Textfile < Pathname
  # OS X comm can't handle lines > 2K bytes.
  # See http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
  COMM_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gcomm' : 'comm')
  SORT_CMD = (RUBY_PLATFORM =~ /darwin/ ? 'gsort' : 'sort')

  def initialize(p1)#, options = {})
    super(p1)
  end

  # Sorts file and removes any duplicate records.
  def sort(options='')
    with_tempcopy do |tempcopy|
      sh "#{SORT_CMD} #{tempcopy} | uniq > #{self}"
    end
  end

  protected
  def sh(cmd)
    %x[ #{cmd} ]
    self
  end

  def with_tempcopy
    tempcopy = Tempfile.new(self.class.name)
    tempcopy.write(self.read)
    tempcopy.close
    yield tempcopy.path
    tempcopy.unlink
    self
  end
end