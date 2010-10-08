unless :symbol.respond_to? :size
  class Symbol
    def size
      to_s.size
    end
  end
end
