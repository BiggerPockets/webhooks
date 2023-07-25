class Event < ApplicationRecord
  def application
    payload.dig('data', 'app', 'name') || '<unknown>'
  end

  def name
    "app.#{resource}.#{action}"
  end

  def name_in_past_tense
    "#{name}d"
  end

  def resource
    payload['resource'] || '<unknown>'
  end

  def action
    payload['action'] || '<unknown>'
  end

  def user
    payload['actor'] || {}
  end

  def utm_campaign
    payload.dig('context', 'campaign', 'name')
  end

  def utm_medium
    payload.dig('context', 'campaign', 'medium')
  end

  def utm_content
    payload.dig('context', 'campaign', 'content')
  end

  def utm_source
    payload.dig('context', 'campaign', 'source')
  end

  def utm_term
    payload.dig('context', 'campaign', 'term')
  end

  def compressed_utms
    "c::#{utm_campaign}/m::#{utm_medium}/s::#{utm_source}/t::#{utm_term}/c::#{utm_content}"
  end

  def user_id
    payload['userId']
  end

  def anonymous_id
    payload['anonymousId']
  end

  def guid?(id)
    id.to_s.match?(/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/)
  end

  def fake_guid?(id)
    id.split('-').all? { |group| group.size == 4 }
  end

  def user_id_format
    if user_id.blank?
      'blank'
    elsif fake_guid?(user_id)
      'fake_guid'
    elsif guid?(user_id)
      'guid'
    elsif user_id.match?(/^[0-9]+$/)
      'social_user'
    else
      'invalid'
    end
  end

  def anonymous_id_format
    if anonymous_id.blank?
      'blank'
    elsif fake_guid?(anonymous_id)
      'fake_guid'
    elsif guid?(anonymous_id)
      'guid'
    else
      'invalid'
    end
  end

  def either_user_id_or_anoymous_id_invalid?
    user_id_format == 'invalid' || anonymous_id_format == 'invalid'
  end

  def self.truncate_to_recent!
    order(created_at: :desc).offset(100).in_batches.destroy_all
  end
end
