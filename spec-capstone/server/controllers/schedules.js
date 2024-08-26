const pool = require("../util/database");

const schedulesController = {
  addStoreSchedule: (req, res) => {
    const { DayOfWeek, StoreID, OpeningTime, ClosingTime } = req.body;

    if (!DayOfWeek || !StoreID || !OpeningTime || !ClosingTime) {
      return res.status(400).json({ message: "All fields are required" });
    }

    pool.query(
      "CALL AddNewStoreSchedule(?, ?, ?, ?)",
      [DayOfWeek, StoreID, OpeningTime, ClosingTime],
      (error) => {
        if (error) {
          console.error("Error executing stored procedure:", error);
          return res
            .status(500)
            .json({ message: "Error adding store schedule" });
        }

        res.status(200).json({ message: "Store schedule added successfully" });
      }
    );
  },

  getStoreSchedule: (req, res) => {
    const storeId = req.params.storeId;
    console.log("Fetching schedule for store ID:", storeId);

    pool.query(
      "SELECT DayOfWeek, OpeningTime, ClosingTime FROM storeschedule WHERE storeID = ?",
      [storeId],
      (error, results) => {
        if (error) {
          console.error("Error fetching schedule:", error);
          return res.status(500).json({ message: "Error fetching schedule" });
        }

        console.log("Fetched schedule data:", results);
        res.status(200).json(results);
      }
    );
  },

  deleteScheduleDay: (req, res) => {
    const { DayOfWeek, StoreID } = req.body;

    if (!DayOfWeek || !StoreID) {
      return res
        .status(400)
        .json({ message: "DayOfWeek and StoreID are required" });
    }

    pool.query(
      "CALL DeleteScheduleDay(?, ?)",
      [DayOfWeek, StoreID],
      (error) => {
        if (error) {
          console.error("Error executing stored procedure:", error);
          return res
            .status(500)
            .json({ message: "Error deleting schedule day" });
        }

        res.status(200).json({ message: "Schedule day deleted successfully" });
      }
    );
  },
};

module.exports = schedulesController;
