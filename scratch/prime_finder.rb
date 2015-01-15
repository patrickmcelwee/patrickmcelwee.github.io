class Enumerator::Lazy
  def select_using_past_results
    primes = []
    Lazy.new(self) do |yielder, *values|
      result = yield *values, primes
      if result
        real_value = values.first
        primes << real_value
        yielder << real_value
      end
    end
  end

end

class PrimeFinder 

  def nth_prime(n)
    (2..Float::INFINITY).lazy.select_using_past_results{|x, known_primes| prime? x, known_primes}.first(n).last
  end

  def prime?(n, known_primes)
    sqrt = Math.sqrt(n) + 1
    known_primes.take_while{|x| x < sqrt}.none? { |x| n % x == 0 }
  end

end

describe PrimeFinder do

  it 'works for first prime' do
    expect(subject.nth_prime(1)).to eq(2)
  end

  it 'works for second prime' do
    expect(subject.nth_prime(2)).to eq(3)
  end

  it 'works for third prime' do
    expect(subject.nth_prime(3)).to eq(5)
  end

  it 'works for 10,001st prime' do
    #non-optimized version takes about 600 msec
    #'optimized' version takes about 900 msec
    expect(subject.nth_prime(10001)).to eq(104743)
  end
end
