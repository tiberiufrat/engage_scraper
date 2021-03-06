class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  belongs_to :form, optional: true
  has_many :lessons, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end
end
