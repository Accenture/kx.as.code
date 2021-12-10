import WelcomeBanner from '../partials/dashboard/WelcomeBanner';
import FilterButton from '../partials/actions/FilterButton';
import Datepicker from '../partials/actions/Datepicker';
import DashboardCard01 from '../partials/dashboard/DashboardCard01';
import DashboardCard04 from '../partials/dashboard/DashboardCard04';
import DashboardCard05 from '../partials/dashboard/DashboardCard05';
import DashboardCard06 from '../partials/dashboard/DashboardCard06';
import DashboardCard07 from '../partials/dashboard/DashboardCard07';


function Dashboard() {



  return (

    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      {/* Applications Header */}
      <div className="text-white text-xl font-bold py-5 italic">MY DASHBOARD</div>

      {/* Dashboard actions */}
      < div className="sm:flex sm:justify-end sm:items-center mb-8" >

        {/* Right: Actions */}
        < div className="grid grid-flow-col sm:auto-cols-max justify-start sm:justify-end gap-2" >
          {/* Filter button */}
          < FilterButton />
          {/* Datepicker built with flatpickr */}
          < Datepicker />
          {/* Add view button */}
          < button className="btn bg-gray-500 hover:bg-gray-600 text-white" >
            <svg className="w-4 h-4 fill-current opacity-50 flex-shrink-0" viewBox="0 0 16 16">
              <path d="M15 7H9V1c0-.6-.4-1-1-1S7 .4 7 1v6H1c-.6 0-1 .4-1 1s.4 1 1 1h6v6c0 .6.4 1 1 1s1-.4 1-1V9h6c.6 0 1-.4 1-1s-.4-1-1-1z" />
            </svg>
            <span className="hidden xs:block ml-2">Add view</span>
          </ button>
        </div >

      </div >

      {/* Cards */}
      <div className="grid grid-cols-12 gap-6" >

        < DashboardCard01 />
        < DashboardCard01 />
        < DashboardCard01 />
        
        {/* Bar chart (Direct vs Indirect) */}
        < DashboardCard04 />
        {/* Line chart (Real Time Value) */}
        < DashboardCard05 />
        {/* Doughnut chart (Top Countries) */}
        < DashboardCard06 />
        {/* Table (Top Channels) */}
        < DashboardCard07 />
        {/* Line chart (Sales Over Time) */}
      </div>
    </div>
  );
}

export default Dashboard;