class RenameTypeColumnPmu < ActiveRecord::Migration
  def change
    # rename the of column 'type' in pmus into 'pmu_type' since
    # Rails DB reserves 'type' for inheritance purpose
    rename_column :pmus, :type, :pmu_type
  end
end
