# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_230_613_114_013) do
  create_table 'checks', force: :cascade do |t|
    t.string 'name'
    t.string 'cron'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'url'
    t.string 'status'
    t.boolean 'active'
    t.string 'job'
    t.datetime 'last_contact_at'
    t.datetime 'next_contact_at'
    t.datetime 'tls_expires_at'
    t.integer 'tls_expires_in_days'
    t.index ['tls_expires_at'], name: 'index_checks_on_tls_expires_at'
  end

  create_table 'status_changes', force: :cascade do |t|
    t.string 'status'
    t.integer 'check_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['check_id'], name: 'index_status_changes_on_check_id'
  end

  add_foreign_key 'status_changes', 'checks'
end
