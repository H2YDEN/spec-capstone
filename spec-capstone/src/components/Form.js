import { useState, useContext, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import AuthContext from "../store/authContext";

const Form = () => {
  const { state } = useContext(AuthContext);
  const navigate = useNavigate();

  const [isAddStore, setIsAddStore] = useState(false);
  const [isEditSchedule, setIsEditSchedule] = useState(false);

  const [storeId, setStoreId] = useState("");
  const [productName, setProductName] = useState("");
  const [productPrice, setProductPrice] = useState("");
  const [soldBy, setSoldBy] = useState("");
  const [productImage, setProductImage] = useState("");
  const [productDescription, setProductDescription] = useState("");
  const [stockQuantity, setStockQuantity] = useState("");

  const [storeName, setStoreName] = useState("");
  const [isActive, setIsActive] = useState(true);
  const [establishmentDate, setEstablishmentDate] = useState("");
  const [streetName, setStreetName] = useState("");
  const [city, setCity] = useState("");
  const [stateUS, setState] = useState("");
  const [zipCode, setZipCode] = useState("");

  const [dow, setDow] = useState("");
  const [openingHour, setOpeningHour] = useState("");
  const [openingMinute, setOpeningMinute] = useState("");
  const [closingHour, setClosingHour] = useState("");
  const [closingMinute, setClosingMinute] = useState("");
  const [schedule, setSchedule] = useState([]);

  const [storeList, setStoreList] = useState([]);

  const [showStoreIds, setShowStoreIds] = useState(false);
  const [showSchedule, setShowSchedule] = useState(false);

  useEffect(() => {
    axios
      .get("/stores", {
        headers: {
          authorization: state.token,
        },
      })
      .then((response) => {
        const storeData = response.data
          .filter((store) => store.ownerId === state.userId)
          .map((store) => ({ id: store.StoreID, name: store.StoreName }));
        setStoreList(storeData);
      })
      .catch((err) => console.log(err));
  }, [state.token, state.userId]);

  const handleSubmitProduct = (e) => {
    e.preventDefault();
    axios
      .post(
        "/products",
        {
          storeId,
          productName,
          productPrice,
          soldBy,
          productImage,
          productDescription,
          stockQuantity,
          userId: state.userId,
        },
        {
          headers: {
            authorization: state.token,
          },
        }
      )
      .then(() => {
        navigate("/profile");
      })
      .catch((err) => console.log(err));
  };

  const handleSubmitStore = (e) => {
    e.preventDefault();
    axios
      .post(
        "/stores",
        {
          storeName,
          isActive,
          establishmentDate,
          streetName,
          city,
          stateUS,
          zipCode,
          ownerId: state.userId,
        },
        {
          headers: {
            authorization: state.token,
          },
        }
      )
      .then(() => {
        navigate("/profile");
      })
      .catch((err) => {
        if (err.response && err.response.data && err.response.data.message) {
          console.log(err.response.data.message);
        } else {
          console.error("Error during store creation:", err);
          alert("An error occurred during store creation. Please try again.");
        }
      });
  };

  const handleSubmitSchedule = (e) => {
    e.preventDefault();

    const openingTime = `${openingHour.padStart(
      2,
      "0"
    )}:${openingMinute.padStart(2, "0")}`;
    const closingTime = `${closingHour.padStart(
      2,
      "0"
    )}:${closingMinute.padStart(2, "0")}`;

    axios
      .post(
        "/schedules/add",
        {
          DayOfWeek: dow,
          StoreID: storeId,
          OpeningTime: openingTime,
          ClosingTime: closingTime,
        },
        {
          headers: {
            Authorization: state.token,
          },
        }
      )
      .then((response) => {
        console.log("Schedule saved successfully:", response.data);
        setStoreId("");
        setDow("");
        setOpeningHour("");
        setOpeningMinute("");
        setClosingHour("");
        setClosingMinute("");
      })
      .catch((error) => {
        console.error("Error saving schedule:", error);
        if (error.response) {
          console.error("Error response data:", error.response.data);
          console.error("Error response status:", error.response.status);
        }
      });
  };

  const handleGetSchedule = async () => {
    try {
      if (!storeId) {
        console.error("Store ID is required to fetch schedule");
        return;
      }

      const response = await axios.get(`/stores/${storeId}/schedule`, {
        headers: {
          Authorization: state.token,
        },
      });

      console.log("Fetched schedule data:", response.data);

      const scheduleData = response.data.map((schedule) => ({
        dow: schedule.DayOfWeek,
        openingTime: schedule.OpeningTime,
        closingTime: schedule.ClosingTime,
      }));
      setSchedule(scheduleData);
      setShowSchedule(true);
    } catch (error) {
      console.error("Error fetching schedule:", error);
    }
  };

  const handleDeleteScheduleDay = (e) => {
    e.preventDefault();

    axios
      .delete("/schedules/delete", {
        data: {
          DayOfWeek: dow,
          StoreID: storeId,
        },
        headers: {
          Authorization: state.token,
        },
      })
      .then((response) => {
        console.log("Schedule day deleted successfully:", response.data);
        alert("Successfully Deleted. Refresh to see changes.");
        setStoreId("");
        setDow("");
        setOpeningHour("");
        setOpeningMinute("");
        setClosingHour("");
        setClosingMinute("");
      })
      .catch((error) => {
        console.error(
          "Error deleting schedule day:",
          error.response?.data || error.message
        );
      });
  };

  {
    showSchedule && schedule.length > 0 && (
      <div className="schedule-info">
        <h3>Schedule for Store {storeId}</h3>
        {schedule.map((sch, index) => (
          <div key={index}>
            <p>
              <strong>Day of Week:</strong> {sch.dow}
            </p>
            <p>
              <strong>Opening Time:</strong> {sch.openingTime}
            </p>
            <p>
              <strong>Closing Time:</strong> {sch.closingTime}
            </p>
            <hr />
          </div>
        ))}
      </div>
    );
  }

  const handleGetStoreIds = async () => {
    try {
      const response = await axios.get("/stores", {
        headers: {
          Authorization: state.token,
        },
      });

      console.log("Fetched store data:", response.data);
      const storeData = response.data.map((store) => ({
        id: store.StoreID,
        name: store.StoreName,
      }));
      setStoreList(storeData);
      setShowStoreIds(true);
    } catch (error) {
      console.error("Error fetching store IDs:", error);
    }
  };

  return (
    <main>
      {!isEditSchedule && (
        <button className="form-btn" onClick={() => setIsAddStore(!isAddStore)}>
          Switch to {isAddStore ? "Product" : "Store"}
        </button>
      )}

      <div className="form-container">
        {isEditSchedule ? (
          <form className="form add-post-form" onSubmit={handleSubmitSchedule}>
            <input
              type="text"
              placeholder="Store ID"
              value={storeId}
              onChange={(e) => setStoreId(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="Day of the Week"
              value={dow}
              onChange={(e) => setDow(e.target.value)}
              className="form-input add-post-input"
            />
            <div className="time-inputs">
              <input
                type="number"
                placeholder="Opening Hour (24h)"
                value={openingHour}
                onChange={(e) => setOpeningHour(e.target.value)}
                className="form-input add-post-input"
                min="0"
                max="23"
                step="1"
              />
              <input
                type="number"
                placeholder="Opening Minute"
                value={openingMinute}
                onChange={(e) => setOpeningMinute(e.target.value)}
                className="form-input add-post-input"
                min="0"
                max="59"
                step="1"
              />
              <input
                type="number"
                placeholder="Closing Hour (24h)"
                value={closingHour}
                onChange={(e) => setClosingHour(e.target.value)}
                className="form-input add-post-input"
                min="0"
                max="23"
                step="1"
              />
              <input
                type="number"
                placeholder="Closing Minute"
                value={closingMinute}
                onChange={(e) => setClosingMinute(e.target.value)}
                className="form-input add-post-input"
                min="0"
                max="59"
                step="1"
              />
            </div>
            <button className="form-btn" type="submit">
              Save Schedule
            </button>
            <button
              className="form-btn"
              onClick={handleDeleteScheduleDay}
              type="button"
            >
              Delete Schedule Day
            </button>
            <button
              className="form-btn"
              onClick={handleGetSchedule}
              type="button"
            >
              Get Schedule
            </button>
            <button
              className="form-btn"
              onClick={handleGetStoreIds}
              type="button"
            >
              Get Store IDs
            </button>
            <button
              className="form-btn"
              onClick={() => setIsEditSchedule(false)}
            >
              Back
            </button>
          </form>
        ) : isAddStore ? (
          <form className="form add-post-form" onSubmit={handleSubmitStore}>
            <input
              type="text"
              placeholder="Store Name"
              value={storeName}
              onChange={(e) => setStoreName(e.target.value)}
              className="form-input add-post-input"
            />
            <div className="status-inputs">
              <div className="radio-btn">
                <label htmlFor="active-status">Active:</label>
                <input
                  type="radio"
                  name="status"
                  id="active-status"
                  value={true}
                  onChange={() => setIsActive(true)}
                  checked={isActive === true}
                />
              </div>
              <div className="radio-btn">
                <label htmlFor="inactive-status">Inactive:</label>
                <input
                  type="radio"
                  name="status"
                  id="inactive-status"
                  value={false}
                  onChange={() => setIsActive(false)}
                  checked={isActive === false}
                />
              </div>
            </div>
            <input
              type="date"
              placeholder="Establishment Date"
              value={establishmentDate}
              onChange={(e) => setEstablishmentDate(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="Street Name"
              value={streetName}
              onChange={(e) => setStreetName(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="City"
              value={city}
              onChange={(e) => setCity(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="State"
              value={stateUS}
              onChange={(e) => setState(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="Zip Code"
              value={zipCode}
              onChange={(e) => setZipCode(e.target.value)}
              className="form-input add-post-input"
            />
            <button className="form-btn">Submit</button>
            <button
              className="form-btn"
              onClick={() => setIsEditSchedule(true)}
            >
              Edit Existing Store Schedule
            </button>
          </form>
        ) : (
          <form className="form add-post-form" onSubmit={handleSubmitProduct}>
            <input
              type="text"
              placeholder="Store ID"
              value={storeId}
              onChange={(e) => setStoreId(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="Product Name"
              value={productName}
              onChange={(e) => setProductName(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="Product Price"
              value={productPrice}
              onChange={(e) => setProductPrice(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="number"
              placeholder="Stock Quantity"
              value={stockQuantity}
              onChange={(e) => setStockQuantity(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="Sold By"
              value={soldBy}
              onChange={(e) => setSoldBy(e.target.value)}
              className="form-input add-post-input"
            />
            <input
              type="text"
              placeholder="Product Image URL"
              value={productImage}
              onChange={(e) => setProductImage(e.target.value)}
              className="form-input add-post-input"
            />
            <textarea
              placeholder="Product Description"
              value={productDescription}
              onChange={(e) => setProductDescription(e.target.value)}
              className="form-input add-post-input"
            />
            <button className="form-btn">Submit Product</button>
          </form>
        )}
      </div>

      <div className="info-container">
        {showStoreIds && storeList.length > 0 && (
          <div className="store-info">
            <h3>Available Store IDs</h3>
            <ul>
              {storeList.map(({ id, name }) => (
                <li key={id}>
                  <strong>{id}:</strong> {name}
                </li>
              ))}
            </ul>
          </div>
        )}

        {showSchedule && schedule.length > 0 && (
          <div className="schedule-info">
            <h3>Schedule for Store {storeId}</h3>
            {schedule.map((sch, index) => (
              <div key={index}>
                <p>
                  <strong>Day of Week:</strong> {sch.dow}
                </p>
                <p>
                  <strong>Opening Time:</strong> {sch.openingTime}
                </p>
                <p>
                  <strong>Closing Time:</strong> {sch.closingTime}
                </p>
                <hr />
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  );
};

export default Form;
