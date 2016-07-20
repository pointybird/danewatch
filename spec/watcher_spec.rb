require 'spec_helper'

module DaneWatch
  describe 'Watcher' do
    describe '.difference_report' do
      it 'reports nothing if no changes in sets' do
        old_dogs = { 'Pooch' => 'Available - Waiting List',
                     'Mutt' => 'Available' }
        new_dogs = { 'Mutt' => 'Available',
                     'Pooch' => 'Available - Waiting List' }

        expect(Watcher.difference_report(old_dogs, new_dogs)).to be_empty
      end

      it 'reports changes between sets' do
        old_dogs = { 'Pooch' => 'Available - Waiting List',
                     'Mutt' => 'Available',
                     'Sammy' => 'Available' }
        new_dogs = { 'Pooch' => 'Available - Waiting List',
                     'Sammy' => 'Pending Adoption',
                     'Rex' => 'Under Evaluation - Waiting List Available' }

        report = Watcher.difference_report(old_dogs, new_dogs)

        expect(report).to include('Mutt is no longer available')
        expect(report).to include("Sammy has changed from 'Available' to 'Pending Adoption'")
        expect(report).to include("Rex has been added with a status of 'Under Evaluation - Waiting List Available'")
      end
    end
  end
end
