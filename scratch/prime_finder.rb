class PrimeFinder 

  def nth_prime(n)
    (2..Float::INFINITY).lazy.select{|x| prime? x}.first(n).last
  end

  def prime?(n)
    (2..Math.sqrt(n)).none? { |x| n % x == 0 }
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
    expect(subject.nth_prime(10001)).to eq(104743)
  end
end
