RSpec.describe Ruice do

  class DependencyA

  end

  class DependencyB
    def initialize
      @dependency_a = Ruice::Dependency.new DependencyA
    end

    attr_reader :dependency_a
  end

  before do
    @container = Ruice::Container.new(
      {
        x: {
          y: {
            z: 'x_y_z'
          }
        },
        y: 'z'
      },
      'production'
    )
  end

  it 'has a version number' do
    expect(Ruice::VERSION).not_to be nil
  end

  it 'fails with properties nil' do
    expect { Ruice::Container.new(nil) }.to raise_error('Container properties can not be nil')
  end

  it 'fails with properties not Hash' do
    expect { Ruice::Container.new('string') }.to raise_error('Container properties is not a Hash')
  end

  it 'fails with env nil' do
    expect { Ruice::Container.new({}, nil) }.to raise_error('Environment can not be nil')
  end

  it 'fails with env not String' do
    expect { Ruice::Container.new({}, {}) }.to raise_error('Environment must be a string')
  end

  it 'has default environment set to :default' do
    expect(Ruice::Container.new.env).to eq(:default)
  end

  it 'has valid environment when set' do
    expect(@container.env).to eq(:production)
  end

  it 'has environment set as property' do
    expect(@container.lookup_property('env')).to eq('production')
  end

  it 'returns valid level 1 property when set' do
    expect(@container.lookup_property('y')).to eq('z')
  end

  it 'returns valid level 2 property for 3 layer property' do
    expect(@container.lookup_property('x.y')).to eq(z: 'x_y_z')
  end

  it 'returns valid level N property when set' do
    expect(@container.lookup_property('x.y.z')).to eq('x_y_z')
  end

  it 'returns valid level N property when set' do
    expect { @container.lookup_property('x.y.z.e') }.to raise_error('Can not access value subkey for non-hash x_y_z')
  end

  it 'returns default value for missing property' do
    expect(@container.lookup_property('not_exists', 'my default')).to eq('my default')
  end
end
