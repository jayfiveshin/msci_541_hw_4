class Array
  def mean
    reduce(:+).to_f / size
  end
end
