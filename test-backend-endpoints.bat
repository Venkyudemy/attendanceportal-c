@echo off
echo.
echo ========================================
echo Backend Endpoint Test
echo ========================================
echo.

echo Testing backend health...
curl -X GET http://localhost:5000/api/health
echo.
echo.

echo Testing employee endpoint...
curl -X GET http://localhost:5000/api/employee
echo.
echo.

echo Testing if check-in-with-image endpoint exists...
echo (This will show 400/404 error which is expected without proper data)
curl -X POST http://localhost:5000/api/employee/test123/check-in-with-image
echo.
echo.

echo ========================================
echo If you see responses above, backend is running!
echo If you see "connection refused", start backend with: npm start
echo ========================================
echo.

pause

