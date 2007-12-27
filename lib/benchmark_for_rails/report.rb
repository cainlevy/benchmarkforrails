class BenchmarkForRails::Report
  PADDING = 2

  attr_accessor :rows
  def initialize
    self.rows = []
  end

  def render(*headers)
    headers.each_index do |i|
      print headers[i].to_s.ljust(width_of_column(i, headers[i].length + PADDING), ' ')
    end
    puts ""

    headers.each_index do |i|
      print '-' * (width_of_column(i) - PADDING)
      print ' ' * PADDING
    end
    puts ""

    rows.each do |row|
      row.each_index do |i|
        print row[i].to_s.ljust(width_of_column(i), ' ')
      end
      puts ""
    end
  end

  def width_of_column(i, min = 8)
    @column_widths ||= []
    @column_widths[i] = (rows.collect{|r| r[i]}.collect{|c| c.to_s.length + PADDING} << min).max if @column_widths[i].nil?
    @column_widths[i]
  end
end
