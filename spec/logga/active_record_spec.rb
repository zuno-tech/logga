# frozen_string_literal: true

RSpec.describe Logga::ActiveRecord do
  with_model :log_entry do
    table do |t|
      t.string :author_id
      t.string :author_name
      t.string :author_type
      t.string :body
      t.string :loggable_id
      t.string :loggable_type
      t.timestamps null: false
    end
  end

  let(:fake_author) { { id: "1", name: "Foo", type: "User" } }

  describe "creating stuff" do
    with_model :stuff do
      table do |t|
        t.string :name
        t.boolean :active
        t.timestamps null: false
      end

      model do
        attr_accessor :author

        has_many :log_entries, as: :loggable, dependent: :destroy
        add_log_entries_for :create
      end
    end

    let(:stuff) { Stuff.new(name: "Some Stuff", active: true) }

    context "without an author" do
      before { stuff.save! }

      it { expect(stuff.log_entries.count).to eq(1) }
      it { expect(stuff.log_entries[0].body).to eq("Stuff created") }
    end

    context "with an author" do
      before do
        stuff.author = fake_author
        stuff.save!
      end

      it { expect(stuff.log_entries.count).to eq(1) }
      it { expect(stuff.log_entries[0].body).to eq("Stuff created") }
      it { expect(stuff.log_entries[0].author_id).to eq("1") }
      it { expect(stuff.log_entries[0].author_name).to eq("Foo") }
      it { expect(stuff.log_entries[0].author_type).to eq("User") }
    end
  end

  describe "creating things on stuff" do
    with_model :stuff do
      table do |t|
        t.string :name
        t.timestamps null: false
      end

      model do
        attr_accessor :author

        has_many :log_entries, as: :loggable, dependent: :destroy
        has_many :things, dependent: :destroy
      end
    end

    with_model :thing do
      table do |t|
        t.string :name
        t.boolean :active
        t.references :stuff
        t.timestamps null: false
      end

      model do
        attr_accessor :author

        belongs_to :stuff
        add_log_entries_for :create, to: :stuff
      end
    end

    let(:stuff) { Stuff.create!(name: "Some Stuff") }
    let(:thing) { Thing.new(name: "Some Thing", active: true, stuff:) }

    context "without an author" do
      before { thing.save! }

      it { expect(stuff.log_entries.count).to eq(1) }
      it { expect(stuff.log_entries[0].body).to eq("Thing created") }
    end

    context "with an author on stuff" do
      before do
        stuff.author = fake_author
        thing.save!
      end

      it { expect(stuff.log_entries.count).to eq(1) }
      it { expect(stuff.log_entries[0].body).to eq("Thing created") }
      it { expect(stuff.log_entries[0].author_id).to eq("1") }
      it { expect(stuff.log_entries[0].author_name).to eq("Foo") }
      it { expect(stuff.log_entries[0].author_type).to eq("User") }
    end

    context "with an author on thing" do
      before do
        thing.author = fake_author
        thing.save!
      end

      it { expect(stuff.log_entries.count).to eq(1) }
      it { expect(stuff.log_entries[0].body).to eq("Thing created") }
      it { expect(stuff.log_entries[0].author_id).to eq("1") }
      it { expect(stuff.log_entries[0].author_name).to eq("Foo") }
      it { expect(stuff.log_entries[0].author_type).to eq("User") }
    end
  end

  describe "updating stuff" do
    with_model :stuff do
      table do |t|
        t.string :name
        t.boolean :active
        t.timestamps null: false
      end

      model do
        attr_accessor :author

        has_many :log_entries, as: :loggable, dependent: :destroy
        add_log_entries_for :update
      end
    end

    let(:stuff) { Stuff.new(name: "Some Stuff", active: true) }
    let(:body) { "Stuff active set to false\nStuff updated at set to 2022-08-21 10:52:24 UTC" }

    before do
      Timecop.freeze(DateTime.parse("2022-08-21 10:51:24 UTC"))
      stuff.save!
      Timecop.freeze(DateTime.parse("2022-08-21 10:52:24 UTC"))
      stuff.update!(active: false)
    end

    it { expect(stuff.log_entries.count).to eq(1) }
    it { expect(stuff.log_entries[0].body).to eq(body) }
  end

  describe "with custom fields and allowed_fields" do
    with_model :stuff do
      table do |t|
        t.string :name
        t.boolean :active
        t.timestamps null: false
      end

      model do
        attr_accessor :author

        has_many :log_entries, as: :loggable, dependent: :destroy
        add_log_entries_for :create,
                            :update,
                            allowed_fields: %i[active],
                            fields: {
                              created_at: ->(record) { "Stuff created at #{record.created_at}" },
                              active: lambda { |_record, _field, old_value, new_value|
                                "Active changed from #{old_value} to #{new_value}"
                              }
                            }
      end
    end

    let(:stuff) { Stuff.new(name: "Some Stuff", active: true) }

    before do
      Timecop.freeze(DateTime.parse("2022-08-21 10:51:24 UTC"))
      stuff.save!
      Timecop.freeze(DateTime.parse("2022-08-21 10:52:24 UTC"))
      stuff.update!(active: false, name: "Some Other Stuff")
    end

    it { expect(stuff.log_entries.count).to eq(2) }
    it { expect(stuff.log_entries[0].body).to eq("Stuff created at 2022-08-21 10:51:24 UTC") }
    it { expect(stuff.log_entries[1].body).to eq("Active changed from true to false") }
  end

  describe "with global and local exclude_fields" do
    with_model :stuff do
      table do |t|
        t.string :name
        t.boolean :active
        t.timestamps null: false
      end

      model do
        attr_accessor :author

        has_many :log_entries, as: :loggable, dependent: :destroy
        add_log_entries_for :update, exclude_fields: %i[active]
      end
    end

    let(:stuff) { Stuff.new(name: "Some Stuff", active: true) }

    before do
      Logga.configure do |config|
        config.excluded_fields = %i[created_at updated_at]
      end

      Timecop.freeze(DateTime.parse("2022-08-21 10:51:24 UTC"))
      stuff.save!

      Timecop.freeze(DateTime.parse("2022-08-21 10:52:24 UTC"))
      stuff.update!(active: false)
    end

    after do
      Logga.configure do |config|
        config.excluded_fields = []
      end
    end

    it { expect(stuff.log_entries.count).to eq(0) }
  end

  describe "with logging turned off" do
    with_model :stuff do
      table do |t|
        t.string :name
        t.boolean :active
        t.timestamps null: false
      end

      model do
        has_many :log_entries, as: :loggable, dependent: :destroy
        add_log_entries_for :create
      end
    end

    let(:stuff) { Stuff.new(name: "Some Stuff", active: true) }

    before do
      Logga.configure do |config|
        config.enabled = false
      end

      Timecop.freeze(DateTime.parse("2022-08-21 10:51:24 UTC"))
      stuff.save!
    end

    after do
      Logga.configure do |config|
        config.enabled = true
      end
    end

    it { expect(stuff.log_entries.count).to eq(0) }
  end
end
