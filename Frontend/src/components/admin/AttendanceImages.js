import React, { useState, useEffect } from 'react';
import './AttendanceImages.css';

const AttendanceImages = () => {
  const [attendanceData, setAttendanceData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedDate, setSelectedDate] = useState(() => {
    // Get today's date in YYYY-MM-DD format (local timezone)
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  });
  const [error, setError] = useState(null);
  const [debugInfo, setDebugInfo] = useState(null);

  useEffect(() => {
    fetchAttendanceImages();
  }, [selectedDate]);

  const fetchAttendanceImages = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Get API URL using the same method as api.js
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

      console.log('📸 Fetching attendance images for date:', selectedDate);

      const response = await fetch(`${API_URL}/employee/attendance`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error('Failed to fetch attendance data');
      }

      const employees = await response.json();
      console.log('📊 Received employees data:', employees.length);
      console.log('Full employee data:', JSON.stringify(employees, null, 2));
      
      // SIMPLIFIED LOGIC - Show ALL employees with images from today's record
      const formattedData = [];
      
      employees.forEach(emp => {
        // Check today's record
        const todayRecord = emp.attendance?.today;
        
        if (todayRecord) {
          const hasCheckInImage = !!todayRecord.checkInImage;
          const hasCheckOutImage = !!todayRecord.checkOutImage;
          
          console.log(`🔍 Employee ${emp.name}:`, {
            hasCheckInImage,
            hasCheckOutImage,
            checkInImagePath: todayRecord.checkInImage,
            checkOutImagePath: todayRecord.checkOutImage,
            date: todayRecord.date
          });
          
          // Debug image URLs
          if (todayRecord.checkInImage) {
            console.log(`📸 Check-in image URL for ${emp.name}:`, window.location.origin + todayRecord.checkInImage);
          }
          if (todayRecord.checkOutImage) {
            console.log(`📸 Check-out image URL for ${emp.name}:`, window.location.origin + todayRecord.checkOutImage);
          }
          
          // If has ANY image, include in results
          if (hasCheckInImage || hasCheckOutImage) {
            formattedData.push({
              id: emp._id,
              name: emp.name,
              email: emp.email,
              department: emp.department || 'N/A',
              position: emp.position || 'N/A',
              employeeId: emp.employeeId || 'N/A',
              checkIn: todayRecord.checkIn || '-',
              checkOut: todayRecord.checkOut || '-',
              checkInImage: todayRecord.checkInImage,
              checkOutImage: todayRecord.checkOutImage,
              status: todayRecord.status || 'Absent',
              hours: todayRecord.hours || 0,
              hasImages: true
            });
            
            console.log(`✅ ADDED ${emp.name} to display list!`);
          } else {
            console.log(`⚠️ Skipped ${emp.name} - no images`);
          }
        } else {
          console.log(`⚠️ ${emp.name}: No today record`);
        }
      });

      console.log('✅ Formatted data with images:', formattedData.length);
      setAttendanceData(formattedData);
      
      // Set debug info for display
      setDebugInfo({
        totalEmployees: employees.length,
        employeesWithImages: formattedData.length,
        selectedDate: selectedDate,
        today: new Date(selectedDate).toLocaleDateString('en-CA'),
        allEmployees: employees.map(e => ({
          name: e.name,
          id: e._id,
          todayDate: e.attendance?.today?.date,
          todayCheckIn: e.attendance?.today?.checkIn,
          todayCheckInImage: e.attendance?.today?.checkInImage,
          todayCheckOut: e.attendance?.today?.checkOut,
          todayCheckOutImage: e.attendance?.today?.checkOutImage,
          recordsCount: e.attendance?.records?.length || 0,
          latestRecord: e.attendance?.records?.length > 0 ? e.attendance.records[e.attendance.records.length - 1] : null
        }))
      });
      
      if (formattedData.length === 0) {
        console.log('⚠️ No employees with images found for date:', selectedDate);
      }
    } catch (err) {
      console.error('❌ Error fetching attendance images:', err);
      setError('Failed to load attendance images. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleDateChange = (e) => {
    setSelectedDate(e.target.value);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Present': return 'success';
      case 'Late': return 'warning';
      case 'Absent': return 'danger';
      case 'On Leave': return 'info';
      default: return 'secondary';
    }
  };

  if (loading) {
    return (
      <div className="attendance-images-page">
        <div className="loading-container">
          <div className="spinner"></div>
          <p>Loading attendance images...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="attendance-images-page">
      <div className="page-header">
        <div className="header-content">
          <h1>📸 Attendance Images</h1>
          <p className="subtitle">Employee check-in and check-out photos (Admin Only)</p>
        </div>
        
        <div className="header-actions">
          <div className="date-filter">
            <label htmlFor="dateFilter">📅 Select Date:</label>
            <input
              type="date"
              id="dateFilter"
              value={selectedDate}
              onChange={handleDateChange}
              max={new Date().toISOString().split('T')[0]}
              className="date-input"
            />
          </div>
          <button onClick={fetchAttendanceImages} className="btn-refresh">
            🔄 Refresh
          </button>
        </div>
      </div>

      {error && (
        <div className="error-message">
          <p>⚠️ {error}</p>
        </div>
      )}

      {debugInfo && (
        <div className="debug-info" style={{
          background: '#fff3cd',
          border: '1px solid #ffc107',
          padding: '15px',
          borderRadius: '8px',
          marginBottom: '20px',
          fontSize: '13px'
        }}>
          <h4 style={{margin: '0 0 10px 0'}}>🔍 Debug Info:</h4>
          <p><strong>Selected Date:</strong> {debugInfo.selectedDate} (formatted: {debugInfo.today})</p>
          <p><strong>Total Employees:</strong> {debugInfo.totalEmployees}</p>
          <p><strong>Employees with Images:</strong> {debugInfo.employeesWithImages}</p>
          <details>
            <summary style={{cursor: 'pointer', fontWeight: 'bold', color: '#667eea'}}>
              📋 All Employees Data (Click to expand) - Check if images exist in database
            </summary>
            <div style={{maxHeight: '400px', overflow: 'auto', marginTop: '10px'}}>
              {debugInfo.allEmployees.map((emp, idx) => (
                <div key={idx} style={{
                  background: emp.todayCheckInImage || emp.todayCheckOutImage ? '#d4edda' : '#f8d7da',
                  padding: '10px',
                  marginBottom: '10px',
                  borderRadius: '6px',
                  fontSize: '12px'
                }}>
                  <div style={{fontWeight: 'bold', marginBottom: '5px'}}>
                    {idx + 1}. {emp.name} ({emp.id ? emp.id.substring(0, 8) : 'N/A'})
                  </div>
                  <div>📅 Today's Date in DB: {emp.todayDate || 'Not set'}</div>
                  <div>🕐 Check-In Time: {emp.todayCheckIn || 'None'}</div>
                  <div>📸 Check-In Image: {emp.todayCheckInImage ? '✅ EXISTS' : '❌ NULL'}</div>
                  {emp.todayCheckInImage && (
                    <div style={{fontSize: '10px', color: '#666', marginLeft: '20px'}}>
                      Path: {emp.todayCheckInImage}
                    </div>
                  )}
                  <div>🕐 Check-Out Time: {emp.todayCheckOut || 'None'}</div>
                  <div>📸 Check-Out Image: {emp.todayCheckOutImage ? '✅ EXISTS' : '❌ NULL'}</div>
                  {emp.todayCheckOutImage && (
                    <div style={{fontSize: '10px', color: '#666', marginLeft: '20px'}}>
                      Path: {emp.todayCheckOutImage}
                    </div>
                  )}
                  <div>📊 Historical Records: {emp.recordsCount}</div>
                  {emp.latestRecord && (
                    <div style={{marginTop: '5px', paddingTop: '5px', borderTop: '1px solid #ccc'}}>
                      <div style={{fontSize: '11px'}}>Latest Record: {emp.latestRecord.date}</div>
                      <div style={{fontSize: '10px'}}>Images: {emp.latestRecord.checkInImage ? '✅' : '❌'} / {emp.latestRecord.checkOutImage ? '✅' : '❌'}</div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </details>
          <p style={{fontSize: '12px', color: '#856404', marginTop: '10px'}}>
            💡 If no images show, check: (1) Employee checked in/out today, (2) Images captured successfully, (3) Database saved image paths
          </p>
        </div>
      )}

      {!error && attendanceData.length === 0 && (
        <div className="no-data">
          <p>📷 No attendance images found for {new Date(selectedDate).toLocaleDateString('en-US', { 
            weekday: 'long', 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
          })}</p>
          <p className="hint">Images appear here when employees check in/out with photos</p>
          {debugInfo && (
            <div style={{marginTop: '20px'}}>
              <p className="hint" style={{color: '#dc3545', fontWeight: 'bold'}}>
                Found {debugInfo.totalEmployees} employees total, but none have photos for this date.
              </p>
              <p className="hint" style={{color: '#856404', marginTop: '10px'}}>
                💡 <strong>IMPORTANT:</strong> Click "📋 All Employees Data" above to see what's in the database!
              </p>
              <p className="hint" style={{color: '#0056b3', marginTop: '10px'}}>
                🔍 Check if: (1) Today's Date in DB matches selected date, (2) Images show "✅ EXISTS", (3) Paths are shown
              </p>
            </div>
          )}
        </div>
      )}

      {!error && attendanceData.length > 0 && (
        <>
          <div className="stats-bar">
            <div className="stat-item">
              <span className="stat-label">Total Employees</span>
              <span className="stat-value">{attendanceData.length}</span>
            </div>
            <div className="stat-item">
              <span className="stat-label">With Check-In Photos</span>
              <span className="stat-value">{attendanceData.filter(e => e.checkInImage).length}</span>
            </div>
            <div className="stat-item">
              <span className="stat-label">With Check-Out Photos</span>
              <span className="stat-value">{attendanceData.filter(e => e.checkOutImage).length}</span>
            </div>
            <div className="stat-item">
              <span className="stat-label">Selected Date</span>
              <span className="stat-value">
                {new Date(selectedDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
              </span>
            </div>
          </div>

          <div className="images-table-container">
            <table className="images-table">
              <thead>
                <tr>
                  <th style={{width: '50px'}}>#</th>
                  <th style={{width: '200px'}}>Employee</th>
                  <th style={{width: '100px'}}>Status</th>
                  <th style={{width: '350px'}}>Check-In</th>
                  <th style={{width: '350px'}}>Check-Out</th>
                  <th style={{width: '80px'}}>Hours</th>
                </tr>
              </thead>
              <tbody>
                {attendanceData.map((emp, index) => (
                  <tr key={emp.id}>
                    <td className="text-center">{index + 1}</td>
                    <td>
                      <div className="employee-info">
                        <div className="employee-avatar">
                          {emp.name.charAt(0).toUpperCase()}
                        </div>
                        <div className="employee-details">
                          <div className="employee-name">{emp.name}</div>
                          <div className="employee-meta">{emp.department}</div>
                          <div className="employee-id">ID: {emp.employeeId || emp.id.substring(0, 8)}</div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span className={`status-badge ${getStatusColor(emp.status)}`}>
                        {emp.status}
                      </span>
                    </td>
                    <td>
                      {emp.checkInImage ? (
                        <div className="attendance-photo-container">
                          <a 
                            href={`${emp.checkInImage}`} 
                            target="_blank" 
                            rel="noopener noreferrer"
                            className="photo-link"
                            onClick={(e) => {
                              // Prevent redirect if image fails to load
                              if (e.target.tagName === 'IMG' && e.target.naturalWidth === 0) {
                                e.preventDefault();
                              }
                            }}
                          >
                            <img
                              src={`${emp.checkInImage}`}
                              alt="Check-in"
                              className="attendance-photo checkin"
                              onLoad={(e) => {
                                console.log('✅ Check-in image loaded successfully:', emp.checkInImage);
                              }}
                              onError={(e) => {
                                console.error('❌ Failed to load check-in image:', emp.checkInImage);
                                console.error('   Full URL:', window.location.origin + emp.checkInImage);
                                e.target.style.display = 'none';
                                e.target.nextSibling.style.display = 'flex';
                              }}
                            />
                            <div className="image-error-fallback" style={{display: 'none', width: '100px', height: '100px', backgroundColor: '#f8f9fa', border: '2px dashed #dee2e6', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column'}}>
                              <div style={{fontSize: '24px', marginBottom: '8px'}}>📷</div>
                              <div style={{fontSize: '12px', color: '#6c757d', textAlign: 'center'}}>Image<br/>Not Found</div>
                            </div>
                            <div className="photo-overlay">
                              <span>🔍 View Full Size</span>
                            </div>
                          </a>
                          <div className="photo-info">
                            <div className="time-badge checkin-time">
                              ⏰ {emp.checkIn}
                            </div>
                            <div className="photo-label">📸 Photo captured</div>
                          </div>
                        </div>
                      ) : (
                        <div className="no-photo-placeholder">
                          <div className="placeholder-icon">📷</div>
                          <div className="placeholder-text">No Photo</div>
                          <div className="time-text">{emp.checkIn}</div>
                        </div>
                      )}
                    </td>
                    <td>
                      {emp.checkOutImage ? (
                        <div className="attendance-photo-container">
                          <a 
                            href={`${emp.checkOutImage}`} 
                            target="_blank" 
                            rel="noopener noreferrer"
                            className="photo-link"
                            onClick={(e) => {
                              // Prevent redirect if image fails to load
                              if (e.target.tagName === 'IMG' && e.target.naturalWidth === 0) {
                                e.preventDefault();
                              }
                            }}
                          >
                            <img
                              src={`${emp.checkOutImage}`}
                              alt="Check-out"
                              className="attendance-photo checkout"
                              onLoad={(e) => {
                                console.log('✅ Check-out image loaded successfully:', emp.checkOutImage);
                              }}
                              onError={(e) => {
                                console.error('❌ Failed to load check-out image:', emp.checkOutImage);
                                console.error('   Full URL:', window.location.origin + emp.checkOutImage);
                                e.target.style.display = 'none';
                                e.target.nextSibling.style.display = 'flex';
                              }}
                            />
                            <div className="image-error-fallback" style={{display: 'none', width: '100px', height: '100px', backgroundColor: '#f8f9fa', border: '2px dashed #dee2e6', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column'}}>
                              <div style={{fontSize: '24px', marginBottom: '8px'}}>📷</div>
                              <div style={{fontSize: '12px', color: '#6c757d', textAlign: 'center'}}>Image<br/>Not Found</div>
                            </div>
                            <div className="photo-overlay">
                              <span>🔍 View Full Size</span>
                            </div>
                          </a>
                          <div className="photo-info">
                            <div className="time-badge checkout-time">
                              ⏰ {emp.checkOut}
                            </div>
                            <div className="photo-label">📸 Photo captured</div>
                          </div>
                        </div>
                      ) : (
                        <div className="no-photo-placeholder">
                          <div className="placeholder-icon">📷</div>
                          <div className="placeholder-text">No Photo</div>
                          <div className="time-text">{emp.checkOut}</div>
                        </div>
                      )}
                    </td>
                    <td className="text-center">
                      <div className="hours-badge">
                        {emp.hours > 0 ? `${emp.hours.toFixed(1)}h` : '-'}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
};

export default AttendanceImages;

