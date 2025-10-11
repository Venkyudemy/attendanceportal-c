import React, { useState, useEffect } from 'react';
import './AttendanceCalendar.css';

const AttendanceCalendar = ({ employeeId, isOpen, onClose }) => {
  const [calendarData, setCalendarData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [selectedMonth, setSelectedMonth] = useState(new Date());
  const [previewImage, setPreviewImage] = useState(null);

  useEffect(() => {
    if (isOpen && employeeId) {
      fetchMonthlyData();
    }
  }, [isOpen, employeeId, selectedMonth]);

  const fetchMonthlyData = async () => {
    try {
      setLoading(true);
      setError(null);

      const month = selectedMonth.getMonth() + 1;
      const year = selectedMonth.getFullYear();

      // Get API URL using the same method as other components
      const getApiBaseUrl = () => {
        if (window.env && window.env.REACT_APP_API_URL) {
          return window.env.REACT_APP_API_URL;
        }
        if (process.env.REACT_APP_API_URL) {
          return process.env.REACT_APP_API_URL;
        }
        return process.env.NODE_ENV === 'production' ? '/api' : 'http://localhost:5000/api';
      };
      const API_URL = getApiBaseUrl();
      const token = localStorage.getItem('token');

      console.log('📅 Fetching monthly attendance for employee:', employeeId);

      const response = await fetch(`${API_URL}/employee/${employeeId}/monthly-attendance-images?month=${month}&year=${year}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error('Failed to fetch monthly attendance data');
      }

      const data = await response.json();
      setCalendarData(data);
      console.log('✅ Monthly attendance data loaded:', data);
    } catch (err) {
      console.error('❌ Error fetching monthly attendance:', err);
      setError('Failed to load monthly attendance data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleMonthChange = (direction) => {
    const newMonth = new Date(selectedMonth);
    if (direction === 'prev') {
      newMonth.setMonth(newMonth.getMonth() - 1);
    } else {
      newMonth.setMonth(newMonth.getMonth() + 1);
    }
    setSelectedMonth(newMonth);
  };

  const getStatusColor = (status, isWeekend) => {
    if (isWeekend) return 'weekend';
    switch (status) {
      case 'Present': return 'present';
      case 'Late': return 'late';
      case 'Absent': return 'absent';
      case 'On Leave': return 'leave';
      default: return 'absent';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Present': return '✅';
      case 'Late': return '⏰';
      case 'Absent': return '❌';
      case 'On Leave': return '🏖️';
      default: return '❓';
    }
  };

  const formatTime = (time) => {
    if (!time) return '';
    return time;
  };

  if (!isOpen) return null;

  return (
    <div className="attendance-calendar-overlay" onClick={onClose}>
      <div className="attendance-calendar-modal" onClick={(e) => e.stopPropagation()}>
        <div className="calendar-header">
          <div className="header-left">
            <h2>📅 Monthly Attendance Calendar</h2>
            {calendarData && (
              <p className="employee-info">
                {calendarData.employee.name} • {calendarData.employee.department} • ID: {calendarData.employee.employeeId}
              </p>
            )}
          </div>
          <button className="close-btn" onClick={onClose}>✕</button>
        </div>

        <div className="calendar-controls">
          <button 
            className="month-nav-btn" 
            onClick={() => handleMonthChange('prev')}
            disabled={loading}
          >
            ← Previous
          </button>
          <h3 className="month-title">
            {selectedMonth.toLocaleDateString('en-US', { 
              month: 'long', 
              year: 'numeric' 
            })}
          </h3>
          <button 
            className="month-nav-btn" 
            onClick={() => handleMonthChange('next')}
            disabled={loading}
          >
            Next →
          </button>
        </div>

        {loading && (
          <div className="loading-container">
            <div className="spinner"></div>
            <p>Loading attendance calendar...</p>
          </div>
        )}

        {error && (
          <div className="error-message">
            <p>⚠️ {error}</p>
            <button onClick={fetchMonthlyData} className="retry-btn">
              Retry
            </button>
          </div>
        )}

        {calendarData && !loading && !error && (
          <>
            <div className="monthly-stats">
              <div className="stat-card">
                <div className="stat-number">{calendarData.monthlyStats.presentDays}</div>
                <div className="stat-label">Present Days</div>
              </div>
              <div className="stat-card">
                <div className="stat-number">{calendarData.monthlyStats.lateDays}</div>
                <div className="stat-label">Late Days</div>
              </div>
              <div className="stat-card">
                <div className="stat-number">{calendarData.monthlyStats.absentDays}</div>
                <div className="stat-label">Absent Days</div>
              </div>
              <div className="stat-card">
                <div className="stat-number">{calendarData.monthlyStats.daysWithImages}</div>
                <div className="stat-label">Days with Photos</div>
              </div>
              <div className="stat-card">
                <div className="stat-number">{calendarData.monthlyStats.totalHours.toFixed(1)}h</div>
                <div className="stat-label">Total Hours</div>
              </div>
            </div>

            <div className="calendar-legend">
              <h4>Legend:</h4>
              <div className="legend-items">
                <div className="legend-item">
                  <div className="legend-color present"></div>
                  <span>Present</span>
                </div>
                <div className="legend-item">
                  <div className="legend-color late"></div>
                  <span>Late</span>
                </div>
                <div className="legend-item">
                  <div className="legend-color absent"></div>
                  <span>Absent</span>
                </div>
                <div className="legend-item">
                  <div className="legend-color weekend"></div>
                  <span>Weekend</span>
                </div>
                <div className="legend-item">
                  <span className="legend-photo">📸</span>
                  <span>Has Photos</span>
                </div>
              </div>
            </div>

            <div className="calendar-grid">
              <div className="calendar-weekdays">
                {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
                  <div key={day} className="weekday-header">{day}</div>
                ))}
              </div>
              
              <div className="calendar-days">
                {calendarData.calendarData.map((dayData, index) => (
                  <div 
                    key={index} 
                    className={`calendar-day ${getStatusColor(dayData.status, dayData.isWeekend)} ${
                      dayData.hasAttendance ? 'has-attendance' : 'no-attendance'
                    } ${dayData.isWeekend ? 'weekend-day' : ''}`}
                  >
                    <div className="day-number">{dayData.day}</div>
                    
                    {dayData.hasAttendance && (
                      <div className="attendance-info">
                        <div className="status-indicator">
                          <span className="status-icon">{getStatusIcon(dayData.status)}</span>
                        </div>
                        
                        {(dayData.checkInImage || dayData.checkOutImage) && (
                          <div className="photo-indicators">
                            {dayData.checkInImage && (
                              <div className="photo-indicator checkin">
                                <img 
                                  src={dayData.checkInImage} 
                                  alt="Check-in"
                                  className="day-photo"
                                  onClick={() => setPreviewImage({
                                    src: dayData.checkInImage,
                                    type: 'Check-in',
                                    time: dayData.checkIn,
                                    date: dayData.date
                                  })}
                                />
                                <div className="time-info">
                                  <span className="time-label">IN</span>
                                  <span className="photo-time">{formatTime(dayData.checkIn)}</span>
                                </div>
                              </div>
                            )}
                            
                            {dayData.checkOutImage && (
                              <div className="photo-indicator checkout">
                                <img 
                                  src={dayData.checkOutImage} 
                                  alt="Check-out"
                                  className="day-photo"
                                  onClick={() => setPreviewImage({
                                    src: dayData.checkOutImage,
                                    type: 'Check-out',
                                    time: dayData.checkOut,
                                    date: dayData.date
                                  })}
                                />
                                <div className="time-info">
                                  <span className="time-label">OUT</span>
                                  <span className="photo-time">{formatTime(dayData.checkOut)}</span>
                                </div>
                              </div>
                            )}
                          </div>
                        )}
                        
                        {!dayData.checkInImage && !dayData.checkOutImage && dayData.hasAttendance && (
                          <div className="no-photo-indicator">
                            <span className="no-photo-text">No Photos</span>
                            <span className="attendance-time">
                              {dayData.checkIn && formatTime(dayData.checkIn)}
                              {dayData.checkIn && dayData.checkOut && ' - '}
                              {dayData.checkOut && formatTime(dayData.checkOut)}
                            </span>
                          </div>
                        )}
                        
                        {dayData.hours > 0 && (
                          <div className="hours-indicator">
                            {dayData.hours.toFixed(1)}h
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </>
        )}

        {previewImage && (
          <div 
            className="image-preview-overlay"
            onClick={() => setPreviewImage(null)}
          >
            <div className="image-preview-modal" onClick={(e) => e.stopPropagation()}>
              <div className="preview-header">
                <h4>{previewImage.type} Photo</h4>
                <button 
                  className="close-preview-btn" 
                  onClick={() => setPreviewImage(null)}
                >
                  ✕
                </button>
              </div>
              <img 
                src={previewImage.src} 
                alt={previewImage.type}
                className="preview-image"
              />
              <div className="preview-info">
                <p><strong>Date:</strong> {new Date(previewImage.date).toLocaleDateString('en-US')}</p>
                <p><strong>Time:</strong> {previewImage.time}</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AttendanceCalendar;
