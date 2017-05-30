module Reports
  module BatchIterator
    def each_batch(scope, &_block)
      iterator = scope.count(:id) <= Generate::PREVIEW_LIMIT ? 'each' : 'find_each'
      scope.send(iterator) { |i| yield i }
    end
  end
end
