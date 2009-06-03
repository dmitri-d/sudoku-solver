require 'test/unit'
require 'sudokuSolver'

class SudokuTests < Test::Unit::TestCase

    def testVerifyColumnSunnyDay
        verifiable = MockVerifiable.new([Cell.new(1), Cell.new(2), Cell.new(3), Cell.new(4), Cell.new(5), Cell.new(6), Cell.new(7), Cell.new(8), Cell.new(9)])
        assert_equal(true, verifiable.valid?)
    end

    def testVerifyWithDuplicates
        verifiable = MockVerifiable.new([Cell.new(1), Cell.new(2), Cell.new(2), Cell.new(4), Cell.new(5), Cell.new(6), Cell.new(7), Cell.new(8), Cell.new(9)])
        assert_equal(false, verifiable.valid?)
    end

    def testVerifyWithDuplicatesNotFullyPopulated
        verifiable = MockVerifiable.new([Cell.new(1), Cell.new(2), Cell.new(2), Cell.new(4), Cell.new(5)])
        assert_equal(false, verifiable.valid?)
    end

    def testVerifySunnyDayNotFullyPopulated
        verifiable = MockVerifiable.new([Cell.new(1), Cell.new(2), Cell.new(3), Cell.new(4), Cell.new(5)])
        assert_equal(true, verifiable.valid?)
    end

    def testCellWithIllegalValue
        solver = SudokuSolver.new
        assert_raise(RuntimeError) { Cell.new(14) }
    end

    def testCellWithIllegalCharacter
        solver = SudokuSolver.new
        assert_raise(RuntimeError) { Cell.new('a') }
    end

end

class MockVerifiable < Verifiable
    def initialize(inArray)
        @cells = Array.new(inArray)
    end
end
