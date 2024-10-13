import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/list

pub opaque type Cell {
  Known(Int)
  Unknown(Set(Int))
  Invalid(Option(Int))
}

pub fn is_valid(cell: Cell) -> Bool {
  case cell {
    Invalid(_) -> False
    _ -> True
  }
}

pub fn is_unknown(cell: Cell) -> Bool {
  case cell {
    Unknown(_) -> True
    _ -> False
  }
}

pub fn into(cell: Cell, num: Int) -> Cell {
  case cell {
    Known(_) as known -> known
    Unknown(nums) -> {
      case set.contains(nums, num) {
        True -> Known(num)
        False -> Invalid(Some(num))
      }
    }
    Invalid(_) as invalid -> invalid
  }
}

pub fn without(cell: Cell, num: Int) -> Cell {
  case cell {
    Known(_) as known -> known
    Unknown(nums) -> {
      let nums = set.delete(nums, num)
      case set.is_empty(nums) {
        True -> Invalid(None)
        False -> Unknown(nums)
      }
    }
    Invalid(_) as invalid -> invalid
  }
}

pub fn possible_values(cell: Cell) -> Set(Int) {
  case cell {
    Known(num) -> set.new() |> set.insert(num)
    Unknown(nums) -> nums
    Invalid(_) -> set.new()
  }
}

pub fn entropy(cell: Cell) -> Int {
  case cell {
    Known(_) -> 1
    Unknown(nums) -> set.size(nums)
    Invalid(_) -> 0
  }
}

pub fn to_string(cell: Cell) -> String {
  case cell {
    Known(num) -> int.to_string(num)
    Unknown(_) -> "-"
    Invalid(Some(num)) -> int.to_string(num)
    Invalid(None) -> "X"
  }
}

pub fn new() -> Cell { Unknown(set.from_list(list.range(1, 9))) }
