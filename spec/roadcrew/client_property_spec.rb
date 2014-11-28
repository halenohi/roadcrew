require 'spec_helper'

describe Roadcrew::ClientProperty do
  class SimpleModel
    include Roadcrew::ClientProperty
  end
  class OtherModel
    include Roadcrew::ClientProperty
  end

  after do
    SimpleModel.instance_variable_set :@properties, {}
  end

  describe '.property' do
    before do
      SimpleModel.property :id, type: 'Integer'
      SimpleModel.property :title, type: 'String'
      SimpleModel.property :date, type: 'Date'
    end

    it 'propertiesに名前と型が保存されること' do
      expect(SimpleModel.properties[:id]).to eq 'Integer'
      expect(SimpleModel.properties[:title]).to eq 'String'
      expect(SimpleModel.properties[:date]).to eq 'Date'
    end

    it 'インスタンスメソッドが定義されること' do
      SimpleModel.method_defined? :id
      SimpleModel.method_defined? :title
      SimpleModel.method_defined? :date
    end

    it '定義されたメソッドがtype_castを呼ぶこと' do
      model = SimpleModel.new id: '1', title: 'sample', date: '2013-10-23'
      expect(SimpleModel).to receive(:type_cast).with('1', 'Integer')
      model.id
      expect(SimpleModel).to receive(:type_cast).with('sample', 'String')
      model.title
      expect(SimpleModel).to receive(:type_cast).with('2013-10-23', 'Date')
      model.date
    end
  end

  describe '.collection' do
    before do
      SimpleModel.collection :others, type: 'OtherModel'
      OtherModel.property :parent, type: 'SimpleModel'
    end

    it 'propertiesに名前と型が保存されること' do
      expect(SimpleModel.properties[:others]).to eq 'OtherModel'
    end

    it 'インスタンスメソッドが定義されること' do
      SimpleModel.method_defined? :others
    end

    it '定義されたメソッドがtype_castを呼ぶこと' do
      model = SimpleModel.new others: ['1', '2', '3']
      expect(SimpleModel).to receive(:type_cast).with('1', 'OtherModel')
      expect(SimpleModel).to receive(:type_cast).with('2', 'OtherModel')
      expect(SimpleModel).to receive(:type_cast).with('3', 'OtherModel')
      model.others
    end
  end

  describe '.type_cast' do
    context '.cast_as_typeが存在する場合、' do
      it '.cast_as_typeを呼ぶこと' do
        expect(SimpleModel).to receive(:cast_as_string).and_return('casted sample')
        expect(String).to_not receive(:new)
        expect(SimpleModel.type_cast 'sample', 'String').to eq 'casted sample'
      end
    end

    context '.cast_as_typeが存在しない場合、' do
      it 'type.newすること' do
        expect(OtherModel).to receive(:new).with('sample').and_return('OtherModel instance')
        expect(SimpleModel.type_cast 'sample', 'OtherModel').to eq 'OtherModel instance'
      end
    end
  end

  describe '.cast_as_' do
    describe 'string' do
      it '文字列を返すこと' do
        expect(SimpleModel.cast_as_string('sample')).to eq 'sample'
        expect(SimpleModel.cast_as_string('31')).to eq '31'
        expect(SimpleModel.cast_as_string(14)).to eq '14'
        expect(SimpleModel.cast_as_string(:test)).to eq 'test'
      end
    end

    describe 'integer' do
      it '数列を返すこと' do
        expect(SimpleModel.cast_as_integer('sample')).to eq 0
        expect(SimpleModel.cast_as_integer('31')).to eq 31
        expect(SimpleModel.cast_as_integer(14)).to eq 14
        expect(SimpleModel.cast_as_integer(:test)).to eq nil
      end
    end

    describe 'date' do
      it 'Dateを返すこと' do
        expect{SimpleModel.cast_as_date('sample')}.to raise_error ArgumentError
        expect(SimpleModel.cast_as_date('2014-11-30')).to eq Date.parse '2014-11-30'
      end
    end

    describe 'date_time' do
      it 'DateTimeを返すこと' do
        expect{SimpleModel.cast_as_date_time('sample')}.to raise_error ArgumentError
        expect(SimpleModel.cast_as_date_time('2014-11-30')).to eq DateTime.parse '2014-11-30'
      end
    end

    describe 'time' do
      it 'Timeを返すこと' do
        expect(SimpleModel.cast_as_time('sample')).to eq nil
        expect(SimpleModel.cast_as_time('2014-11-30')).to eq Time.zone.parse '2014-11-30'
      end
    end

    describe 'boolean' do
      it 'TrueClassかFalseClassを返すこと' do
        expect(SimpleModel.cast_as_boolean('sample')).to be true
        expect(SimpleModel.cast_as_boolean('true')).to be true
        expect(SimpleModel.cast_as_boolean('false')).to be false
        expect(SimpleModel.cast_as_boolean('1')).to be true
        expect(SimpleModel.cast_as_boolean('0')).to be false
      end
    end

    describe 'float' do
      it 'floatを返すこと' do
        expect(SimpleModel.cast_as_float('sample')).to eq 0.0
        expect(SimpleModel.cast_as_float('1.432')).to eq 1.432
        expect(SimpleModel.cast_as_float(1.432)).to eq 1.432
      end
    end

    describe 'decimal' do
      it 'decimalを返すこと' do
        expect(SimpleModel.cast_as_decimal('sample')).to eq 0.0
        expect(SimpleModel.cast_as_decimal('1.432')).to eq 1.432
        expect(SimpleModel.cast_as_decimal(1.432)).to eq 1.432
      end
    end
  end

  describe '#initialize' do
    before do
      @obj = SimpleModel.new(id: '43', title: 'sample', date: '2014-02-21')
    end
    it '@paramsにattrsを保存すること' do
      expect(@obj.instance_variable_get(:@params)).to eq(id: '43', title: 'sample', date: '2014-02-21')
    end

    it 'accessibleなメソッドを定義すること' do
      expect(@obj.id).to eq 43
      expect(@obj.id = '54').to eq '54'
      expect(@obj.id).to eq 54
      expect(@obj.title).to eq 'sample'
      expect(@obj.date).to eq(Date.parse '2014-02-21')
    end

    it 'propertyに満たない場合はエラーになること' do
      SimpleModel.instance_variable_set :@properties, { id: 'Integer', title: 'String' }
      expect{SimpleModel.new(id: '21')}.to raise_error Roadcrew::ClientProperty::InvalidAttributes
      expect(SimpleModel.new(id: '21', title: 'sample', date: '2013-05-16')).to be_an_instance_of SimpleModel
    end
  end
end
