class Some::Klass
  include Some::Module
  def hello; 'hello' end
  def self.world; 'world' end
  def yielder; yield end
  def echoer(*args); args end
end