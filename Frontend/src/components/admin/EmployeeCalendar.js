import React, { useState, useEffect } from 'react';
import './EmployeeCalendar.css';

const EmployeeCalendar = ({ employee, isOpen, onClose }) => {
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [attendanceData, setAttendanceData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [selectedDay, setSelectedDay] = useState(null);

  useEffect(() => {
    if (isOpen && employee) {
      fetchMonthlyAttendance();
    }
  }, [isOpen, employee, currentMonth]);

  const fetchMonthlyAttendance = async () => {
    if (!employee) return;

    try {
      setLoading(true);
      
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

      const month = currentMonth.getMonth() + 1;
      const year = currentMonth.getFullYear();

      console.log(`📅 Fetching monthly attendance for ${employee.name} - ${month}/${year}`);

      const response = await fetch(`${API_URL}/employee/monthly-attendance/${employee.id}?month=${month}&year=${year}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error('Failed to fetch monthly attendance data');
      }

      const data = await response.json();
      console.log('📊 Monthly attendance data:', data);
      setAttendanceData(data.attendance || []);
    } catch (error) {
      console.error('❌ Error fetching monthly attendance:', error);
      setAttendanceData([]);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  };

  const getDaysInMonth = (date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDayOfWeek = firstDay.getDay();

    const days = [];
    
    // Add empty cells for days before the first day of the month
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push({ date: null, isEmpty: true });
    }
    
    // Add days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      const dayDate = new Date(year, month, day);
      const attendance = getAttendanceForDate(dayDate);
      const isWeekend = dayDate.getDay() === 0 || dayDate.getDay() === 6;
      
      days.push({ 
        date: dayDate, 
        isEmpty: false,
        attendance: attendance,
        isWeekend: isWeekend,
        isToday: formatDate(dayDate) === formatDate(new Date())
      });
    }
    
    return days;
  };

  const getAttendanceForDate = (date) => {
    if (!date) return null;
    const dateStr = formatDate(date);
    return attendanceData.find(record => record.date === dateStr);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Present': return '#28a745'; // Green
      case 'Late': return '#ffc107'; // Yellow
      case 'Absent': return '#dc3545'; // Red
      case 'On Leave': return '#17a2b8'; // Blue
      case 'Holiday': return '#fd7e14'; // Orange
      default: return '#6c757d'; // Gray
    }
  };

  const getDayBorderColor = (dayData) => {
    if (dayData.isEmpty) return 'transparent';
    if (dayData.isWeekend) return '#e9ecef'; // Light gray for weekends
    if (dayData.attendance) {
      return getStatusColor(dayData.attendance.status);
    }
    return 'transparent'; // No attendance data
  };

  const getDayBackgroundColor = (dayData) => {
    if (dayData.isEmpty) return 'transparent';
    if (dayData.isToday) return '#e3f2fd'; // Light blue for today
    if (dayData.isWeekend) return '#f8f9fa'; // Light gray for weekends
    if (dayData.attendance) {
      switch (dayData.attendance.status) {
        case 'Present': return '#d4edda'; // Light green
        case 'Late': return '#fff3cd'; // Light yellow
        case 'Absent': return '#f8d7da'; // Light red
        case 'On Leave': return '#d1ecf1'; // Light blue
        case 'Holiday': return '#ffeaa7'; // Light orange
        default: return '#f8f9fa'; // Light gray
      }
    }
    return '#ffffff'; // White for no data
  };

  const navigateMonth = (direction) => {
    setCurrentMonth(prev => {
      const newDate = new Date(prev);
      newDate.setMonth(prev.getMonth() + direction);
      return newDate;
    });
  };

  const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  if (!isOpen || !employee) return null;

  const days = getDaysInMonth(currentMonth);
  const monthName = monthNames[currentMonth.getMonth()];
  const year = currentMonth.getFullYear();

  return (
    <div className="employee-calendar-overlay" onClick={onClose}>
      <div className="employee-calendar-modal" onClick={(e) => e.stopPropagation()}>
        <div className="calendar-header">
          <div className="calendar-title">
            <h2>📅 {employee.name}'s Attendance Calendar</h2>
            <p className="employee-info">
              {employee.department} • ID: {employee.employeeId || employee.id.substring(0, 8)}
            </p>
          </div>
          <button className="close-btn" onClick={onClose}>✕</button>
        </div>

        <div className="calendar-navigation">
          <button 
            className="nav-btn" 
            onClick={() => navigateMonth(-1)}
            disabled={loading}
          >
            ← Previous
          </button>
          <h3 className="current-month">
            {monthName} {year}
          </h3>
          <button 
            className="nav-btn" 
            onClick={() => navigateMonth(1)}
            disabled={loading}
          >
            Next →
          </button>
        </div>

        {loading && (
          <div className="loading-indicator">
            <div className="spinner"></div>
            <p>Loading attendance data...</p>
          </div>
        )}

        <div className="calendar-legend">
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
            <div className="legend-color leave"></div>
            <span>Leave/Holiday</span>
          </div>
          <div className="legend-item">
            <div className="legend-color weekend"></div>
            <span>Weekend</span>
          </div>
        </div>

        <div className="calendar-grid">
          <div className="calendar-header-row">
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
              <div key={day} className="day-header">{day}</div>
            ))}
          </div>
          
          <div className="calendar-body">
            {days.map((dayData, index) => {
              const { date, isEmpty, attendance, isWeekend, isToday } = dayData;
              const hasImages = attendance && (attendance.checkInImage || attendance.checkOutImage);
              const borderColor = getDayBorderColor(dayData);
              const backgroundColor = getDayBackgroundColor(dayData);
              
              return (
                <div
                  key={index}
                  className={`calendar-day ${isEmpty ? 'empty' : ''} ${isToday ? 'today' : ''} ${hasImages ? 'has-images' : ''} ${isWeekend ? 'weekend' : ''}`}
                  style={{
                    border: isEmpty ? 'none' : `2px solid ${borderColor}`,
                    backgroundColor: backgroundColor
                  }}
                  onClick={() => {
                    if (date && attendance) {
                      setSelectedDay({ date: date, attendance });
                    }
                  }}
                >
                  {!isEmpty && (
                    <>
                      <div className="day-number">{date.getDate()}</div>
                      {attendance && (
                        <div className="day-attendance">
                          {attendance.checkInImage && (
                            <div className="attendance-indicator checkin">
                              📸
                            </div>
                          )}
                          {attendance.checkOutImage && (
                            <div className="attendance-indicator checkout">
                              📸
                            </div>
                          )}
                          <div 
                            className="status-dot" 
                            style={{ 
                              backgroundColor: getStatusColor(attendance.status) 
                            }}
                          ></div>
                        </div>
                      )}
                      {!attendance && !isWeekend && (
                        <div className="day-attendance">
                          <div className="status-dot" style={{ backgroundColor: '#e9ecef' }}></div>
                        </div>
                      )}
                    </>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {selectedDay && (
          <div className="day-details-modal">
            <div className="day-details-content">
              <div className="day-details-header">
                <h3>
                  📅 {selectedDay.date.toLocaleDateString('en-US', { 
                    weekday: 'long', 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric' 
                  })}
                </h3>
                <button 
                  className="close-details-btn" 
                  onClick={() => setSelectedDay(null)}
                >
                  ✕
                </button>
              </div>
              
              <div className="day-details-body">
                {selectedDay.attendance ? (
                  <>
                    <div className="attendance-summary">
                      <div className="summary-item">
                        <span className="label">Status:</span>
                        <span 
                          className="status-badge"
                          style={{ backgroundColor: getStatusColor(selectedDay.attendance.status) }}
                        >
                          {selectedDay.attendance.status}
                        </span>
                      </div>
                      <div className="summary-item">
                        <span className="label">Hours:</span>
                        <span className="value">{selectedDay.attendance.hours || 0}h</span>
                      </div>
                    </div>

                    <div className="attendance-photos">
                      {selectedDay.attendance.checkInImage && (
                        <div className="photo-section">
                          <h4>🕐 Check-In</h4>
                          <div className="photo-container">
                            <img 
                              src={selectedDay.attendance.checkInImage} 
                              alt="Check-in photo"
                              className="attendance-photo"
                            />
                            <div className="photo-time">
                              {selectedDay.attendance.checkIn || 'No time recorded'}
                            </div>
                          </div>
                        </div>
                      )}

                      {selectedDay.attendance.checkOutImage && (
                        <div className="photo-section">
                          <h4>🕐 Check-Out</h4>
                          <div className="photo-container">
                            <img 
                              src={selectedDay.attendance.checkOutImage} 
                              alt="Check-out photo"
                              className="attendance-photo"
                            />
                            <div className="photo-time">
                              {selectedDay.attendance.checkOut || 'No time recorded'}
                            </div>
                          </div>
                        </div>
                      )}

                      {!selectedDay.attendance.checkInImage && !selectedDay.attendance.checkOutImage && (
                        <div className="no-photos">
                          <p>📷 No photos captured for this day</p>
                        </div>
                      )}
                    </div>
                  </>
                ) : (
                  <div className="no-attendance">
                    <p>📅 No attendance recorded for this day</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default EmployeeCalendar;
