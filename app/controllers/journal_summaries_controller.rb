# frozen_string_literal: true

class JournalSummariesController < ApplicationController
  def create
    @kid = Kid.find(params[:kid_id])
    authorize! :read, @kid

    @kid.update!(journal_summary: JournalSummarizer.new(@kid).call, journal_summary_generated_at: Time.zone.now)
    redirect_to kid_path(@kid), notice: t('flash.journal_summary_generated')
  rescue JournalSummarizer::Error => e
    redirect_to kid_path(@kid), alert: e.message
  end
end
