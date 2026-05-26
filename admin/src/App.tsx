import React, { useState, useEffect } from 'react';
import { 
  Shield, 
  Map, 
  Users, 
  Activity, 
  Settings, 
  Volume2, 
  AlertTriangle, 
  CheckCircle, 
  TrendingUp, 
  Clock, 
  UserCheck, 
  Search, 
  X, 
  Check, 
  LogOut 
} from 'lucide-react';
import { io } from 'socket.io-client';

// Mock active emergencies for real-time dashboard visualization
interface Emergency {
  id: string;
  victim: string;
  type: string;
  location: string;
  coords: { lat: number; lng: number };
  responders: number;
  time: string;
  status: 'active' | 'resolved' | 'false-alarm';
}

interface ResponderApplication {
  id: string;
  name: string;
  vehicle: string;
  plate: string;
  blood: string;
  phone: string;
  appliedDate: string;
}

export default function App() {
  const [activeTab, setActiveTab] = useState<'dashboard' | 'map' | 'responders' | 'analytics' | 'settings'>('dashboard');
  const [incidents, setIncidents] = useState<Emergency[]>([
    {
      id: 'SOS-9082',
      victim: 'Sarah Connor',
      type: 'Robbery Attempt',
      location: 'Broadway Ave & 5th St',
      coords: { lat: 37.7749, lng: -122.4194 },
      responders: 2,
      time: '2 mins ago',
      status: 'active',
    },
    {
      id: 'SOS-1120',
      victim: 'John Doe',
      type: 'Medical Accident',
      location: '124 Market St, Sector G',
      coords: { lat: 37.7801, lng: -122.4120 },
      responders: 1,
      time: '14 mins ago',
      status: 'active',
    },
    {
      id: 'SOS-0941',
      victim: 'Mary Jane',
      type: 'Harassment',
      location: 'Central Plaza Mall Escalator',
      coords: { lat: 37.7690, lng: -122.4280 },
      responders: 0,
      time: '34 mins ago',
      status: 'resolved',
    }
  ]);

  const [applications, setApplications] = useState<ResponderApplication[]>([
    {
      id: 'APP-102',
      name: 'David Miller',
      vehicle: 'Motorcycle (Suzuki)',
      plate: 'KHI-9081',
      blood: 'O+',
      phone: '+1 (555) 789-0123',
      appliedDate: 'Today, 10:45 AM',
    },
    {
      id: 'APP-103',
      name: 'Dr. Elizabeth Shaw',
      vehicle: 'Car (Honda Civic)',
      plate: 'LHR-2234',
      blood: 'AB-',
      phone: '+1 (555) 890-1234',
      appliedDate: 'Yesterday, 4:15 PM',
    }
  ]);

  // Real-time server connection simulation
  useEffect(() => {
    // Graceful Socket.IO listener connection setup
    const socket = io('http://localhost:5000', { autoConnect: false });
    socket.connect();

    socket.on('connect', () => {
      console.log('⚡ Connected to safety gateway via React Dashboard');
    });

    return () => {
      socket.disconnect();
    };
  }, []);

  const handleApprove = (id: string, name: string) => {
    setApplications(applications.filter(app => app.id !== id));
    alert(`✅ ${name} has been successfully verified and added to the community responder mesh network.`);
  };

  const handleReject = (id: string, name: string) => {
    setApplications(applications.filter(app => app.id !== id));
    alert(`❌ Application for ${name} rejected.`);
  };

  const handleResolve = (id: string) => {
    setIncidents(incidents.map(inc => inc.id === id ? { ...inc, status: 'resolved' } : inc));
  };

  return (
    <div className="flex h-screen bg-[#0A0E1A] overflow-hidden text-white font-sans">
      
      {/* ─── SIDEBAR NAVIGATION ────────────────────────────────────────── */}
      <aside className="w-72 bg-[#0E1326] border-r border-[#1E2440] flex flex-col justify-between">
        <div>
          {/* Header Branding */}
          <div className="p-6 border-b border-[#1E2440] flex items-center gap-3">
            <div className="p-2.5 bg-pulseRed/10 border border-pulseRed/30 rounded-xl">
              <Shield className="h-7 w-7 text-pulseRed" />
            </div>
            <div>
              <h1 className="font-extrabold text-xl tracking-wider">PulseSOS</h1>
              <p className="text-[10px] text-cyberCyan font-bold tracking-widest uppercase">Command Center</p>
            </div>
          </div>

          {/* Navigation Links */}
          <nav className="p-4 space-y-2 mt-4">
            <button 
              onClick={() => setActiveTab('dashboard')}
              className={`w-full flex items-center gap-4 px-4 py-3.5 rounded-xl transition duration-200 font-medium ${activeTab === 'dashboard' ? 'bg-[#1E2440] text-cyberCyan border-l-4 border-cyberCyan' : 'text-slate-400 hover:bg-[#141832] hover:text-white'}`}
            >
              <Activity className="h-5 w-5" />
              <span>C&C Dashboard</span>
            </button>
            <button 
              onClick={() => setActiveTab('map')}
              className={`w-full flex items-center gap-4 px-4 py-3.5 rounded-xl transition duration-200 font-medium ${activeTab === 'map' ? 'bg-[#1E2440] text-cyberCyan border-l-4 border-cyberCyan' : 'text-slate-400 hover:bg-[#141832] hover:text-white'}`}
            >
              <Map className="h-5 w-5" />
              <span>Tactical Live Map</span>
            </button>
            <button 
              onClick={() => setActiveTab('responders')}
              className={`w-full flex items-center gap-4 px-4 py-3.5 rounded-xl transition duration-200 font-medium ${activeTab === 'responders' ? 'bg-[#1E2440] text-cyberCyan border-l-4 border-cyberCyan' : 'text-slate-400 hover:bg-[#141832] hover:text-white'}`}
            >
              <Users className="h-5 w-5" />
              <span>Responders Mesh</span>
              {applications.length > 0 && (
                <span className="ml-auto bg-pulseRed text-white text-xs px-2.5 py-0.5 rounded-full font-bold">
                  {applications.length}
                </span>
              )}
            </button>
            <button 
              onClick={() => setActiveTab('analytics')}
              className={`w-full flex items-center gap-4 px-4 py-3.5 rounded-xl transition duration-200 font-medium ${activeTab === 'analytics' ? 'bg-[#1E2440] text-cyberCyan border-l-4 border-cyberCyan' : 'text-slate-400 hover:bg-[#141832] hover:text-white'}`}
            >
              <TrendingUp className="h-5 w-5" />
              <span>Alert Analytics</span>
            </button>
            <button 
              onClick={() => setActiveTab('settings')}
              className={`w-full flex items-center gap-4 px-4 py-3.5 rounded-xl transition duration-200 font-medium ${activeTab === 'settings' ? 'bg-[#1E2440] text-cyberCyan border-l-4 border-cyberCyan' : 'text-slate-400 hover:bg-[#141832] hover:text-white'}`}
            >
              <Settings className="h-5 w-5" />
              <span>System Settings</span>
            </button>
          </nav>
        </div>

        {/* Footer profile log out */}
        <div className="p-4 border-t border-[#1E2440] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 bg-cyberCyan/10 border border-cyberCyan/30 rounded-full flex items-center justify-center">
              <span className="font-bold text-cyberCyan">A</span>
            </div>
            <div>
              <p className="text-sm font-bold">Administrator</p>
              <p className="text-xs text-slate-500">SysOp Online</p>
            </div>
          </div>
          <button className="p-2 text-slate-400 hover:text-pulseRed hover:bg-pulseRed/10 rounded-lg transition duration-200">
            <LogOut className="h-5 w-5" />
          </button>
        </div>
      </aside>

      {/* ─── MAIN CONTENT VIEWPORT ────────────────────────────────────── */}
      <main className="flex-1 flex flex-col overflow-y-auto bg-[#0A0E1A]">
        
        {/* Top bar header */}
        <header className="h-20 bg-[#0E1326] border-b border-[#1E2440] flex items-center justify-between px-8 z-10 shrink-0">
          <div className="flex items-center gap-3">
            <h2 className="text-xl font-bold capitalize">{activeTab} Interface</h2>
            <div className="h-2.5 w-2.5 rounded-full bg-safeGreen animate-ping"></div>
            <span className="text-xs font-bold text-safeGreen">Pulse Gateway Online</span>
          </div>
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3.5 top-3 h-4.5 w-4.5 text-slate-500" />
              <input 
                type="text" 
                placeholder="Search logs, victims..." 
                className="bg-[#141832] border border-[#1E2440] rounded-xl pl-11 pr-4 py-2.5 text-sm w-72 focus:outline-none focus:border-cyberCyan transition"
              />
            </div>
          </div>
        </header>

        {/* Dynamic page container */}
        <div className="p-8 flex-1">
          
          {/* TAB 1: C&C DASHBOARD */}
          {activeTab === 'dashboard' && (
            <div className="space-y-8">
              {/* Metrics cards grid */}
              <div className="grid grid-cols-4 gap-6">
                <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-slate-400 font-semibold mb-1">Active Emergencies</p>
                    <h3 className="text-3xl font-extrabold text-pulseRed">
                      {incidents.filter(i => i.status === 'active').length}
                    </h3>
                  </div>
                  <div className="p-4 bg-pulseRed/15 border border-pulseRed/20 rounded-2xl emergency-pulse-glow">
                    <AlertTriangle className="h-7 w-7 text-pulseRed" />
                  </div>
                </div>

                <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-slate-400 font-semibold mb-1">Avg Response Time</p>
                    <h3 className="text-3xl font-extrabold text-cyberCyan">3.4 mins</h3>
                  </div>
                  <div className="p-4 bg-cyberCyan/15 border border-cyberCyan/20 rounded-2xl">
                    <Clock className="h-7 w-7 text-cyberCyan" />
                  </div>
                </div>

                <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-slate-400 font-semibold mb-1">Verified Responders</p>
                    <h3 className="text-3xl font-extrabold text-safeGreen">1,482</h3>
                  </div>
                  <div className="p-4 bg-safeGreen/15 border border-safeGreen/20 rounded-2xl">
                    <UserCheck className="h-7 w-7 text-safeGreen" />
                  </div>
                </div>

                <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-slate-400 font-semibold mb-1">Resolution Rate</p>
                    <h3 className="text-3xl font-extrabold text-slate-200">98.4%</h3>
                  </div>
                  <div className="p-4 bg-slate-500/10 border border-slate-500/20 rounded-2xl">
                    <CheckCircle className="h-7 w-7 text-slate-400" />
                  </div>
                </div>
              </div>

              {/* Main content grid: Active emergencies and Live streams */}
              <div className="grid grid-cols-3 gap-8">
                {/* Active emergency lists */}
                <div className="col-span-2 space-y-6">
                  <h4 className="text-lg font-bold tracking-wide uppercase text-slate-400">Tactical Active Alerts Log</h4>
                  <div className="space-y-4">
                    {incidents.map((incident) => (
                      <div 
                        key={incident.id} 
                        className={`p-6 rounded-2xl border transition duration-200 ${incident.status === 'active' ? 'bg-pulseRed/5 border-pulseRed/25' : 'bg-[#141832] border-[#1E2440]'}`}
                      >
                        <div className="flex justify-between items-start">
                          <div className="flex gap-4">
                            <div className={`p-3.5 rounded-xl ${incident.status === 'active' ? 'bg-pulseRed/15 border border-pulseRed/20' : 'bg-slate-700/20'}`}>
                              <AlertTriangle className={`h-6 w-6 ${incident.status === 'active' ? 'text-pulseRed' : 'text-slate-400'}`} />
                            </div>
                            <div>
                              <div className="flex items-center gap-3">
                                <span className="font-extrabold text-lg text-white">{incident.type}</span>
                                <span className={`text-[10px] px-2 py-0.5 rounded font-bold uppercase ${incident.status === 'active' ? 'bg-pulseRed/20 text-pulseRed' : 'bg-safeGreen/20 text-safeGreen'}`}>
                                  {incident.status}
                                </span>
                              </div>
                              <p className="text-sm text-slate-400 mt-1 font-medium">{incident.location}</p>
                              <div className="flex items-center gap-6 mt-3">
                                <span className="text-xs text-slate-500 font-semibold">ID: {incident.id}</span>
                                <span className="text-xs text-slate-500 font-semibold">Victim: {incident.victim}</span>
                                <span className="text-xs text-cyberCyan font-bold">{incident.responders} Joined Responders</span>
                              </div>
                            </div>
                          </div>

                          <div className="flex flex-col items-end gap-3">
                            <span className="text-xs text-slate-500 font-semibold">{incident.time}</span>
                            {incident.status === 'active' && (
                              <button 
                                onClick={() => handleResolve(incident.id)}
                                className="bg-safeGreen text-deepBlack font-bold text-xs px-4 py-2 rounded-lg hover:bg-safeGreen/80 transition"
                              >
                                FORCE RESOLVE
                              </button>
                            )}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Live logs stream card */}
                <div className="bg-[#0E1326] border border-[#1E2440] rounded-2xl p-6 h-[480px] flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between border-b border-[#1E2440] pb-4 mb-4">
                      <h4 className="font-extrabold text-sm tracking-wider uppercase text-slate-400">Live Telemetry Feed</h4>
                      <Volume2 className="h-5 w-5 text-cyberCyan animate-bounce" />
                    </div>
                    <div className="space-y-4 overflow-y-auto max-h-[340px]">
                      <div className="text-xs space-y-1">
                        <p className="text-slate-500">Today, 21:35:10</p>
                        <p className="text-white font-medium">🚨 SOS signal created for <span className="text-pulseRed font-bold">Sarah Connor</span> (Robbery Attempt)</p>
                      </div>
                      <div className="text-xs space-y-1">
                        <p className="text-slate-500">Today, 21:35:12</p>
                        <p className="text-white font-medium">📣 Notification broadcasted to 28 nearby users</p>
                      </div>
                      <div className="text-xs space-y-1">
                        <p className="text-slate-500">Today, 21:35:28</p>
                        <p className="text-white font-medium">🟢 Volunteer <span className="text-safeGreen font-bold">David Miller</span> accepted task & is en route</p>
                      </div>
                      <div className="text-xs space-y-1">
                        <p className="text-slate-500">Today, 21:34:02</p>
                        <p className="text-white font-medium">💬 Trusted Contacts SMS successfully delivered to 2 recipients</p>
                      </div>
                    </div>
                  </div>
                  <div className="border-t border-[#1E2440] pt-4 text-center">
                    <p className="text-[10px] text-cyberCyan font-bold tracking-widest">SYSTEM ONLINE — LISTENING</p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: TACTICAL LIVE MAP */}
          {activeTab === 'map' && (
            <div className="space-y-6">
              <h4 className="text-lg font-bold tracking-wide uppercase text-slate-400">Real-Time Tactical Map Projection</h4>
              
              {/* Futuristic Map Mock Canvas */}
              <div className="relative h-[600px] w-full rounded-2xl bg-[#0E1326] border border-[#1E2440] overflow-hidden flex items-center justify-center">
                
                {/* SVG Cyber grid lines grid */}
                <div className="absolute inset-0 opacity-10 bg-[linear-gradient(to_right,#00E5FF_1px,transparent_1px),linear-gradient(to_bottom,#00E5FF_1px,transparent_1px)] bg-[size:40px_40px]"></div>
                
                {/* Mock target nodes representation */}
                <div className="absolute top-1/4 left-1/3 text-center z-10">
                  <div className="relative flex items-center justify-center">
                    <span className="absolute inline-flex h-12 w-12 rounded-full bg-pulseRed/25 animate-ping"></span>
                    <div className="relative h-6 w-6 rounded-full bg-pulseRed border border-white flex items-center justify-center font-bold text-[9px] text-white">V</div>
                  </div>
                  <div className="bg-[#141832] border border-pulseRed px-3 py-1.5 rounded-lg mt-2 text-[10px] font-bold text-white shadow-xl">
                    Sarah Connor (Robbery SOS)
                  </div>
                </div>

                <div className="absolute top-1/3 left-1/2 text-center z-10">
                  <div className="relative flex items-center justify-center">
                    <div className="h-6 w-6 rounded-full bg-cyberCyan border border-white flex items-center justify-center font-bold text-[9px] text-black">R1</div>
                  </div>
                  <div className="bg-[#141832] border border-[#1E2440] px-3 py-1.5 rounded-lg mt-2 text-[10px] font-bold text-white shadow-xl">
                    David Miller (Motorcycle) - 150m away
                  </div>
                </div>

                <div className="absolute bottom-1/4 right-1/4 text-center z-10">
                  <div className="relative flex items-center justify-center font-bold">
                    <span className="absolute inline-flex h-10 w-10 rounded-full bg-pulseRed/10 animate-ping"></span>
                    <div className="relative h-6 w-6 rounded-full bg-pulseRed border border-white flex items-center justify-center text-[9px] text-white">V</div>
                  </div>
                  <div className="bg-[#141832] border border-pulseRed px-3 py-1.5 rounded-lg mt-2 text-[10px] font-bold text-white shadow-xl">
                    John Doe (Medical SOS)
                  </div>
                </div>

                {/* Radar target lock overlays */}
                <div className="absolute top-8 left-8 p-4 bg-[#141832]/85 border border-[#1E2440] rounded-xl z-10 backdrop-blur">
                  <p className="text-[10px] text-slate-500 font-bold uppercase">Grid coordinates</p>
                  <p className="text-xs text-cyberCyan font-mono mt-0.5">LAT 37.7749 // LNG -122.4194</p>
                </div>

                <div className="absolute bottom-8 right-8 p-4 bg-[#141832]/85 border border-[#1E2440] rounded-xl z-10 backdrop-blur flex items-center gap-4">
                  <div className="h-3 w-3 bg-pulseRed rounded-full animate-ping"></div>
                  <span className="text-xs font-bold uppercase tracking-wider">Tactical Projection Live</span>
                </div>
              </div>
            </div>
          )}

          {/* TAB 3: RESPONDERS MESH APPLICATIONS */}
          {activeTab === 'responders' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <h4 className="text-lg font-bold tracking-wide uppercase text-slate-400">Responder Applications Verification Queue</h4>
                <span className="text-xs bg-[#1E2440] px-4 py-2 border border-[#1E2440] rounded-xl font-bold">
                  {applications.length} Pending Actions
                </span>
              </div>

              {applications.length === 0 ? (
                <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-12 text-center">
                  <Users className="h-16 w-16 text-slate-600 mx-auto mb-4" />
                  <h3 className="font-bold text-lg">No pending applications</h3>
                  <p className="text-slate-500 text-sm mt-1">All applicant volunteer responders have been successfully verified.</p>
                </div>
              ) : (
                <div className="grid grid-cols-2 gap-6">
                  {applications.map((app) => (
                    <div key={app.id} className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6 space-y-4">
                      <div className="flex justify-between items-start">
                        <div className="flex gap-4">
                          <div className="h-12 w-12 bg-cyberCyan/10 border border-cyberCyan/20 rounded-xl flex items-center justify-center">
                            <Users className="h-6 w-6 text-cyberCyan" />
                          </div>
                          <div>
                            <h4 className="font-bold text-lg text-white">{app.name}</h4>
                            <p className="text-xs text-slate-500 mt-0.5">Applied: {app.appliedDate}</p>
                          </div>
                        </div>
                        <span className="text-[10px] text-cyberCyan bg-cyberCyan/10 border border-cyberCyan/20 px-2 py-0.5 rounded font-extrabold uppercase">
                          {app.id}
                        </span>
                      </div>

                      <div className="grid grid-cols-2 gap-4 bg-[#0E1326] p-4 rounded-xl border border-[#1E2440] text-sm">
                        <div>
                          <p className="text-xs text-slate-500 font-semibold mb-0.5">Vehicle Details</p>
                          <p className="font-medium text-slate-200">{app.vehicle}</p>
                        </div>
                        <div>
                          <p className="text-xs text-slate-500 font-semibold mb-0.5">License Plate</p>
                          <p className="font-medium text-slate-200">{app.plate}</p>
                        </div>
                        <div>
                          <p className="text-xs text-slate-500 font-semibold mb-0.5">Blood Type</p>
                          <p className="font-medium text-slate-200">{app.blood}</p>
                        </div>
                        <div>
                          <p className="text-xs text-slate-500 font-semibold mb-0.5">Phone Contact</p>
                          <p className="font-medium text-slate-200">{app.phone}</p>
                        </div>
                      </div>

                      <div className="flex gap-4 pt-2">
                        <button 
                          onClick={() => handleApprove(app.id, app.name)}
                          className="flex-1 bg-safeGreen text-deepBlack font-bold py-3 rounded-xl hover:bg-safeGreen/80 transition flex items-center justify-center gap-2"
                        >
                          <Check className="h-4.5 w-4.5" />
                          APPROVE
                        </button>
                        <button 
                          onClick={() => handleReject(app.id, app.name)}
                          className="flex-1 bg-[#1E2440] hover:bg-[#252C4D] text-slate-300 font-bold py-3 rounded-xl transition flex items-center justify-center gap-2 border border-slate-700"
                        >
                          <X className="h-4.5 w-4.5" />
                          REJECT
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* TAB 4: ALERT ANALYTICS */}
          {activeTab === 'analytics' && (
            <div className="space-y-6">
              <h4 className="text-lg font-bold tracking-wide uppercase text-slate-400">PulseSOS Safety Network Analytics</h4>
              
              <div className="grid grid-cols-2 gap-8">
                {/* Graph Card 1 */}
                <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6">
                  <h5 className="font-bold text-sm tracking-wider uppercase text-slate-400 mb-6">SOS Alerts Over Time</h5>
                  
                  {/* Mock Dynamic SVG Graph */}
                  <div className="h-64 w-full bg-[#0E1326] border border-[#1E2440] rounded-xl flex items-end p-4 relative overflow-hidden">
                    <div className="absolute inset-0 opacity-5 bg-[linear-gradient(to_right,#00E5FF_1px,transparent_1px)] bg-[size:30px_100%]"></div>
                    
                    {/* SVG Line Graph Path represent */}
                    <svg className="absolute inset-0 h-full w-full p-4" viewBox="0 0 100 100" preserveAspectRatio="none">
                      <path 
                        d="M0 80 Q 25 50, 50 60 T 100 20 L 100 100 L 0 100 Z" 
                        fill="rgba(0, 229, 255, 0.05)" 
                        stroke="rgba(0, 229, 255, 0.6)" 
                        strokeWidth="2" 
                      />
                    </svg>

                    <div className="flex justify-between w-full text-[10px] text-slate-500 font-bold uppercase relative z-10">
                      <span>Jan</span>
                      <span>Feb</span>
                      <span>Mar</span>
                      <span>Apr</span>
                      <span>May</span>
                    </div>
                  </div>
                </div>

                {/* Graph Card 2 */}
                <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6">
                  <h5 className="font-bold text-sm tracking-wider uppercase text-slate-400 mb-6">Incident Response Distribution</h5>
                  
                  <div className="h-64 w-full bg-[#0E1326] border border-[#1E2440] rounded-xl flex items-end justify-around p-4 relative overflow-hidden">
                    {/* Columns bar presentation */}
                    <div className="w-12 bg-pulseRed/20 border border-pulseRed/30 rounded-t-lg h-3/4 relative z-10 flex flex-col justify-end text-center p-2">
                      <span className="text-[10px] font-bold text-pulseRed">72%</span>
                      <span className="text-[9px] text-slate-500 mt-2 font-bold uppercase">Robbery</span>
                    </div>
                    <div className="w-12 bg-cyberCyan/20 border border-cyberCyan/30 rounded-t-lg h-1/2 relative z-10 flex flex-col justify-end text-center p-2">
                      <span className="text-[10px] font-bold text-cyberCyan">48%</span>
                      <span className="text-[9px] text-slate-500 mt-2 font-bold uppercase">Medical</span>
                    </div>
                    <div className="w-12 bg-safeGreen/20 border border-safeGreen/30 rounded-t-lg h-1/3 relative z-10 flex flex-col justify-end text-center p-2">
                      <span className="text-[10px] font-bold text-safeGreen">32%</span>
                      <span className="text-[9px] text-slate-500 mt-2 font-bold uppercase">Fire</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 5: SYSTEM SETTINGS */}
          {activeTab === 'settings' && (
            <div className="space-y-6 max-w-4xl">
              <h4 className="text-lg font-bold tracking-wide uppercase text-slate-400">System Admin Control Center</h4>
              
              <div className="bg-[#141832] border border-[#1E2440] rounded-2xl p-6 space-y-6">
                <div className="flex justify-between items-center border-b border-[#1E2440] pb-4">
                  <div>
                    <h5 className="font-bold text-white">Automatic Emergency Broadcast</h5>
                    <p className="text-xs text-slate-500 mt-0.5">Route alerts to neighboring active devices automatically.</p>
                  </div>
                  <input type="checkbox" defaultChecked className="h-5 w-5 accent-cyberCyan" />
                </div>

                <div className="flex justify-between items-center border-b border-[#1E2440] pb-4">
                  <div>
                    <h5 className="font-bold text-white">SMS/WhatsApp Gateway Dispatch</h5>
                    <p className="text-xs text-slate-500 mt-0.5">Ping emergency contacts instantly on active alerts.</p>
                  </div>
                  <input type="checkbox" defaultChecked className="h-5 w-5 accent-cyberCyan" />
                </div>

                <div className="flex justify-between items-center border-b border-[#1E2440] pb-4">
                  <div>
                    <h5 className="font-bold text-white">High-Frequency GPS Tracking</h5>
                    <p className="text-xs text-slate-500 mt-0.5">Ingest coordinates in 3-second buffers during active emergencies.</p>
                  </div>
                  <input type="checkbox" defaultChecked className="h-5 w-5 accent-cyberCyan" />
                </div>

                <div className="pt-4 flex justify-end">
                  <button className="bg-cyberCyan text-deepBlack font-bold px-6 py-3 rounded-xl hover:bg-cyberCyan/80 transition text-sm">
                    SAVE SYSTEM CONFIG
                  </button>
                </div>
              </div>
            </div>
          )}

        </div>
      </main>

    </div>
  );
}
