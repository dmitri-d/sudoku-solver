#!/usr/bin/ruby

class Verifiable
    public
        def initialize
            @cells = Array.new()
            @usedValues = Array.new()
        end
        
        def addCell(cellToAdd)
            @cells.push(cellToAdd)
            cellChanged(cellToAdd) if not cellToAdd.value == 0
        end

        def valid?
            present = Array.new(9, false)
            @cells.each do |cell|
                raise "Expected Cells in Row/Column/Region" if not cell.kind_of?(Cell)
                return false if present[cell.value]
                present[cell.value] = true
            end 
            true
        end
        
        def cellChanged(cell)
            raise "Expected Cells in Row/Column/Region" if not cell.kind_of?(Cell)
            value = cell.value
            raise "Value '#{value}' has already been assigned to another cell" if @usedValues.include?(value)
            @usedValues.push(value)
        end
        
        def availableValues()
            # TODO: don't repeat yourself 
            [1, 2, 3, 4, 5, 6, 7, 8, 9] - @usedValues
        end
        
        def undoLastCellChange
            @usedValues.pop
        end
        
        def to_s
            "#{@cells.length} ---- #{@cells.to_s}"
        end
end

class Board
    public
        def initialize
            @rows = Row * 9
            @columns = Column * 9 
            @regions = Region * 9
            @cells = Array.new
        end
        
        def solve
            return solveImpl(0)
        end
        
        def display
            for i in 0..@cells.length - 1
                print "#{@cells[i]} | "
                puts "\n" if (i + 1)%9 == 0
            end
        end
        
    protected        
        def calculateRegionIndex(index)
            tmp = index/3
            
            return 0 if [0, 3, 6].include?(tmp)
            return 1 if [1, 4, 7].include?(tmp)
            return 2 if [2, 5, 8].include?(tmp)
            return 3 if [9, 12, 15].include?(tmp)
            return 4 if [10, 13, 16].include?(tmp)
            return 5 if [11, 14, 17].include?(tmp)
            return 6 if [18, 21, 24].include?(tmp)
            return 7 if [19, 22, 25].include?(tmp)
            return 8 if [20, 23, 26].include?(tmp)
        end
        
        def solveImpl(index)
            
            return true if index == @cells.length
            return solveImpl(index + 1) if (not @cells[index].value == 0)
            
            cell = @cells[index]
            
            cell.availableValues.each do |value|
                cell.value = value
                if not solveImpl(index + 1)
                    cell.undoLastChange
                    next
                else
                    return true
                end
            end
            
            false
        end
end

class EmptyBoard < Board
    def initialize
        super
        
        for i in 0..80
            rowIndex = i/9
            columnIndex = i%9
            regionIndex = calculateRegionIndex(i)
            
            cell = Cell.new
            @cells.push(cell)
            
            @rows[rowIndex].addCell(cell)
            @columns[columnIndex].addCell(cell)
            @regions[regionIndex].addCell(cell)
        end
    end
end

class CustomBoard < Board
    def initialize(file)
        super()
        raise "'#{file}' is not a file" if not file.kind_of?(File)
        index = 0
        file.each_byte { |byte| 
            if (?0..?9).include?(byte)
                rowIndex = index/9
                columnIndex = index%9
                regionIndex = calculateRegionIndex(index)
                
                cell = Cell.new(byte - ?0)
                @cells.push(cell)
                
                @rows[rowIndex].addCell(cell)
                @columns[columnIndex].addCell(cell)
                @regions[regionIndex].addCell(cell)
                index += 1
            end
        }
        
    end
end

module Multipliable
    def *(number)
        (1..number).collect { new }
    end
end

class Row < Verifiable
    extend Multipliable

    public
        def addCell(cell)
            super(cell)
            cell.row = self
        end
end

class Column < Verifiable
    extend Multipliable

    public
        def addCell(cell)
            super(cell)
            cell.column = self
        end
end

class Region < Verifiable
    extend Multipliable

    public
        def addCell(cell)
            super(cell)
            cell.region = self
        end
end

class Cell
        attr_reader :value
        attr_accessor :column, :row, :region
        
        def initialize(value = 0)
            raise "value '#{value}' is not in range 0..9" if not (0..9).include?(value)
            @value = value
        end
        
        def value=(newValue)
            raise "value '#{newValue}' is not in range: #{@@validCellValues}" if not @@validCellValues.include?(newValue)
            raise "Value '#{newValue}' has already been assigned to another cell" if (not availableValues.include?newValue)
            @value = newValue
            notifyAll
        end
        
        def undoLastChange
            @column.undoLastCellChange
            @row.undoLastCellChange
            @region.undoLastCellChange
            @value = 0
        end
        
        def availableValues
            @column.availableValues & @row.availableValues & @region.availableValues
        end
        
        def to_s
            @value.to_s
        end
        
    private
        @@validCellValues = 1..9
        
        def notifyAll
            @column.cellChanged(self)
            @row.cellChanged(self)
            @region.cellChanged(self)
        end
end

if $0 == __FILE__

#    board = EmptyBoard.new
    board = nil
    File.open("./board", "r") do |file|
        board = CustomBoard.new(file)
    end
    board.display

    puts "Starting..."
    board.display if board.solve
    puts "Done."

end
