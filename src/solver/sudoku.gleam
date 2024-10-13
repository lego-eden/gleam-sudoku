import gleam/iterator
import gleam/io
import gleam/result
import gleam/set
import gleam/option.{ type Option, Some, None }
import gleam/int
import solver/cell.{ type Cell }
import gleam/dict.{ type Dict }
import gleam/list

pub opaque type Sudoku {
  Sudoku(cells: Dict(#(Int, Int), Cell))
}

pub fn new() -> Sudoku {
  Sudoku(
    list.range(0, 8)
    |> list.flat_map(fn(row) {
      list.range(0, 8)
      |> list.map(fn(col) { #(#(row, col), cell.new()) })
    })
    |> dict.from_list
  )
}

fn is_valid(sudoku: Sudoku) -> Bool {
  sudoku.cells
  |> dict.values
  |> list.all(cell.is_valid)
}

fn affected_cells(sudoku: Sudoku, row: Int, col: Int) -> List(#(#(Int, Int), Cell)) {
  sudoku.cells
  |> dict.filter(fn(coords, _) {
    let #(cell_row, cell_col) = coords
    let same_row = cell_row == row
    let same_col = cell_col == col
    let same_box = {
      let row_ok = row / 3 == cell_row / 3
      let col_ok = col / 3 == cell_col / 3
      row_ok && col_ok
    }
    same_row || same_col || same_box
  })
  |> dict.to_list
}

pub fn lowest_entropy(sudoku: Sudoku) -> Option(#(#(Int, Int), Cell)) {
  sudoku.cells
  |> dict.to_list
  |> list.sort(fn(current, next) {
    int.compare(cell.entropy(current.1), cell.entropy(next.1))
  })
  |> list.filter(fn(c) { cell.is_unknown(c.1) })
  |> list.first
  |> option.from_result
}

pub fn solved(sudoku: Sudoku) -> Option(Sudoku) {
  case lowest_entropy(sudoku), is_valid(sudoku) {
    _, False -> None
    None, True -> Some(sudoku)
    Some(#(#(row, col), current_cell)), True -> {
      cell.possible_values(current_cell)
      |> set.to_list
      |> iterator.from_list
      |> iterator.map(fn(num) {
        set(sudoku, row, col, num)
        |> fn(sud) {
          io.println(to_string(sud))
          sud
        }
        |> solved
      })
      |> iterator.find_map(option.to_result(_, Nil))
      |> option.from_result
    }
  }
}

pub fn set(sudoku: Sudoku, row: Int, col: Int, num: Int) -> Sudoku {
  let target_cell: Cell = result.lazy_unwrap(dict.get(sudoku.cells, #(row, col)), fn() { panic })
  let new_grid = dict.insert(sudoku.cells, #(row, col), cell.into(target_cell, num))
  let new_grid = {
    affected_cells(Sudoku(new_grid), row, col)
    |> list.fold(new_grid, fn(acc, next) {
      let coords = next.0
      dict.insert(acc, coords, cell.without(next.1, num))
    })
  }
  Sudoku(new_grid)
}

pub fn to_string(sudoku: Sudoku) -> String {
  let grid: List(List(String)) = {
    use row <- list.map(list.range(0, 8))
    use col <- list.map(list.range(0, 8))
    let current_cell = dict.get(sudoku.cells, #(row, col)) |> result.lazy_unwrap(fn() { panic })
    cell.to_string(current_cell)
  }
  let rows: List(String) = {
    use row <- list.map(grid)
    list.repeat(["", "", " "], 3)
    |> list.flatten
    |> list.map2(row, _, fn(s1, s2) { s1 <> s2 })
    |> list.intersperse(" ")
    |> list.reduce(fn(acc, next) { acc <> next })
    |> result.lazy_unwrap(fn() { panic })
  }
  rows
  |> list.append(["\n"])
  |> list.reduce(fn(acc, next) { acc <> "\n" <> next })
  |> result.lazy_unwrap(fn() { panic })
}

pub fn opt_to_string(sudoku: Option(Sudoku)) -> String {
  option.map(sudoku, to_string) |> option.unwrap("None")
}
