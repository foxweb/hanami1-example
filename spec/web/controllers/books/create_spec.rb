require 'spec_helper'
require 'hanami/helpers'
require_relative '../../../../apps/web/controllers/books/create'

describe Web::Controllers::Books::Create do
  include Hanami::Helpers

  let(:action) { Web::Controllers::Books::Create.new }
  let(:repository) { BookRepository.new }

  before do
    repository.clear
  end

  describe 'with valid params' do
    let(:params) { Hash[book: { title: 'Confident Ruby', author: 'Avdi Grimm' }] }

    it 'is creates a book' do
      action.call(params)
      book = repository.last

      book.id.wont_be_nil
      book.title.must_equal params.dig(:book, :title)
    end

    it 'redirects the user to the books listing' do
      response = action.call(params)

      response[0].must_equal 302
      response[1]['Location'].must_equal routes.books_url
    end
  end

  describe 'with invalid params' do
    let(:params) { Hash[book: {}] }

    it 'returns HTTP client error' do
      response = action.call(params)
      response[0].must_equal 422
    end

    it 'dumps errors in params' do
      action.call(params)
      errors = action.params.errors

      errors.dig(:book, :title).must_equal  ['is missing']
      errors.dig(:book, :author).must_equal ['is missing']
    end
  end
end
