
class VisitsEntry
  attr_accessor :unique, :number_of_visits, :name

  def initialize(lineStr, lineNo)
    lines = lineStr.strip.split " "
    raise 'Incorrect number of values at line ' + lineNo.to_s unless lines.length == 2


    @number_of_visits = Integer lines[1].delete('.'), 10
    raise 'Negative value ' + @number_of_visits.to_s + " at line " + lineNo.to_s if @number_of_visits < 0
    @name = lines[0]
    @unique = true
  end

  def add_new_visit(no_of_visits)
    @number_of_visits += no_of_visits
    @unique = false
  end

  def <=>(obj1)

    if @unique == obj1.unique
      # both unique or both not unique
      return @number_of_visits <=> obj1.number_of_visits
    end

    # if urls are not both unique
    # sort the unique ones to the bottom
    if @unique && !obj1.unique
      return -1
    end

    if obj1.unique && !@unique
      1
    end
  end

  def to_s
    @name + " " + @number_of_visits.to_s +  (@unique ?" unique views \n": " visits ")
  end

end


class Parser

  def initialize
    @visits_hash = {}
  end

  def execute(args)
    begin
      raise "Usage is './parser.rb [path_to_file]'." unless args.length == 1
      line_number = 1
      File.open(args[0], 'r').each do |line|
        visit = VisitsEntry.new(line, line_number)
        url = visit.name

        if @visits_hash.key? url
          @visits_hash[url].add_new_visit visit.number_of_visits
        else
          @visits_hash[url] = visit
        end

        line_number += 1
      end

      @visits_hash.values.sort.reverse_each do |result|
        print result.to_s
      end

    rescue StandardError => e
      $stderr.puts e.message
    end
  end
end
