import { useState, useContext } from "react";
import axios from "axios";
import AuthContext from "../store/authContext";

const Auth = () => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [email, setEmail] = useState("");
  const [securityQuestion, setSecurityQuestion] = useState("");
  const [securityAnswer, setSecurityAnswer] = useState("");
  const [register, setRegister] = useState(true);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [showSecurityQuestion, setShowSecurityQuestion] = useState(false);
  const [securityQuestionText, setSecurityQuestionText] = useState("");
  const [showResetPassword, setShowResetPassword] = useState(false);
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showForgotUsername, setShowForgotUsername] = useState(false);
  const [emailForUsername, setEmailForUsername] = useState("");
  const [foundUsername, setFoundUsername] = useState("");
  const { dispatch } = useContext(AuthContext);

  const handleLogin = (e) => {
    e.preventDefault();
    axios
      .post("/login", { username, password })
      .then((res) => {
        dispatch({ type: "LOGIN", payload: res.data });
      })
      .catch((err) => {
        if (err.response && err.response.data && err.response.data.message) {
          alert(err.response.data.message);
        } else {
          console.error("Error during login:", err);
          alert("Username or password is incorrect.");
        }
      });
  };

  const handleRegister = (e) => {
    e.preventDefault();
    axios
      .post("/register", {
        username,
        password,
        email,
        securityQuestion,
        securityAnswer,
      })
      .then((res) => {
        dispatch({ type: "LOGIN", payload: res.data });
      })
      .catch((err) => {
        if (err.response && err.response.data && err.response.data.message) {
          alert(err.response.data.message);
        } else {
          console.error("Error during registration:", err);
          alert("An error occurred during registration. Please try again.");
        }
      });
  };

  const handleForgotPassword = () => {
    setShowForgotPassword(true);
  };

  const handleUsernameSubmit = (e) => {
    e.preventDefault();
    axios
      .post("/forgot-password", { username })
      .then((res) => {
        setSecurityQuestionText(res.data.securityQuestion);
        setShowSecurityQuestion(true);
      })
      .catch((err) => {
        console.error(err);
        alert("Error fetching security question");
      });
  };

  const handleSecurityAnswerSubmit = (e) => {
    e.preventDefault();
    axios
      .post("/forgot-password-submit", {
        username,
        securityAnswer,
      })
      .then((res) => {
        console.log("Security answer verified:", res.data);
        setShowResetPassword(true);
        setShowForgotPassword(false);
        setShowSecurityQuestion(false);
      })
      .catch((err) => {
        console.error(err);
        alert("Incorrect security answer");
      });
  };

  const handleResetPasswordSubmit = (e) => {
    e.preventDefault();
    axios
      .post("/reset-password", {
        username,
        newPassword,
      })
      .then((res) => {
        console.log("Password reset:", res.data);
        setShowResetPassword(false);
      })
      .catch((err) => {
        console.error(err);
        alert("Error resetting password");
      });
  };

  const handleForgotUsername = () => {
    setShowForgotUsername(true);
  };

  const handleEmailSubmit = (e) => {
    e.preventDefault();
    axios
      .post("/forgot-username", { email: emailForUsername })
      .then((res) => {
        setFoundUsername(res.data.username);
        setShowForgotUsername(false);
        alert(`Your username is: ${res.data.username}`);
      })
      .catch((err) => {
        console.error(err);
        alert("Error fetching username");
      });
  };

  return (
    <main>
      <h1>Welcome!</h1>
      {showForgotPassword && !showSecurityQuestion ? (
        <form className="form auth-form" onSubmit={handleUsernameSubmit}>
          <input
            className="form-input"
            placeholder="Username"
            onChange={(e) => setUsername(e.target.value)}
            value={username}
          />
          <button className="form-btn">Submit Username</button>
        </form>
      ) : null}
      {showSecurityQuestion ? (
        <form className="form auth-form" onSubmit={handleSecurityAnswerSubmit}>
          <input
            className="form-input"
            placeholder="Username"
            onChange={(e) => setUsername(e.target.value)}
            value={username}
            disabled
          />
          <p className="security-question">{securityQuestionText}</p>
          <input
            className="form-input"
            placeholder="Security Answer"
            onChange={(e) => setSecurityAnswer(e.target.value)}
            value={securityAnswer}
          />
          <button className="form-btn">Verify</button>
        </form>
      ) : null}
      {showResetPassword ? (
        <form className="form auth-form" onSubmit={handleResetPasswordSubmit}>
          <input
            className="form-input"
            placeholder="Username"
            onChange={(e) => setUsername(e.target.value)}
            value={username}
            disabled
          />
          <input
            className="form-input"
            placeholder="New Password"
            type="password"
            onChange={(e) => setNewPassword(e.target.value)}
            value={newPassword}
          />
          <input
            className="form-input"
            placeholder="Confirm Password"
            type="password"
            onChange={(e) => setConfirmPassword(e.target.value)}
            value={confirmPassword}
          />
          <button className="form-btn">Reset Password</button>
        </form>
      ) : null}
      {showForgotUsername ? (
        <form className="form auth-form" onSubmit={handleEmailSubmit}>
          <input
            className="form-input"
            placeholder="Email"
            onChange={(e) => setEmailForUsername(e.target.value)}
            value={emailForUsername}
          />
          <button className="form-btn">Submit Email</button>
        </form>
      ) : null}
      {foundUsername && (
        <p className="found-username">Your username is: {foundUsername}</p>
      )}

      {showForgotUsername ||
      showForgotPassword ||
      showSecurityQuestion ||
      showResetPassword ? (
        <button
          className="form-btn"
          onClick={() => {
            setShowForgotPassword(false);
            setShowSecurityQuestion(false);
            setShowForgotUsername(false);
            setShowResetPassword(false);
          }}
        >
          Back
        </button>
      ) : (
        <>
          <form
            className="form auth-form"
            onSubmit={register ? handleRegister : handleLogin}
          >
            <input
              className="form-input"
              placeholder="Username"
              onChange={(e) => setUsername(e.target.value)}
              value={username}
            />
            <input
              className="form-input"
              placeholder="Password"
              onChange={(e) => setPassword(e.target.value)}
              value={password}
              type="password"
            />
            {register && (
              <>
                <input
                  className="form-input"
                  placeholder="Email"
                  onChange={(e) => setEmail(e.target.value)}
                  value={email}
                />
                <input
                  className="form-input"
                  placeholder="Security Question"
                  onChange={(e) => setSecurityQuestion(e.target.value)}
                  value={securityQuestion}
                />
                <input
                  className="form-input"
                  placeholder="Security Answer"
                  onChange={(e) => setSecurityAnswer(e.target.value)}
                  value={securityAnswer}
                />
              </>
            )}
            <button className="form-btn">
              {register ? "Sign Up" : "Login"}
            </button>
          </form>
          <button className="form-btn" onClick={handleForgotPassword}>
            Forgot Password?
          </button>
          <button className="form-btn" onClick={handleForgotUsername}>
            Forgot Username?
          </button>
        </>
      )}
      {showForgotPassword ||
      showSecurityQuestion ||
      showResetPassword ||
      showForgotUsername ? null : (
        <button className="form-btn" onClick={() => setRegister(!register)}>
          Need to {register ? "Login" : "Sign Up"}?
        </button>
      )}
    </main>
  );
};

export default Auth;
