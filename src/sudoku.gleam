import gleam/io
import solver/sudoku

pub fn main() {
  let sud =
    sudoku.new()
    |> sudoku.set(0, 0, 2)
    |> sudoku.set(0, 1, 1)

  let impossible =
    sudoku.new()
    |> sudoku.set(0, 0, 1)
    |> sudoku.set(0, 1, 2)
    |> sudoku.set(0, 2, 3)
    |> sudoku.set(1, 0, 4)
    |> sudoku.set(1, 1, 5)
    |> sudoku.set(1, 2, 6)
    |> sudoku.set(2, 3, 7)

  io.println(sud |> sudoku.solved |> sudoku.opt_to_string)
  io.println(impossible |> sudoku.solved |> sudoku.opt_to_string)

}
